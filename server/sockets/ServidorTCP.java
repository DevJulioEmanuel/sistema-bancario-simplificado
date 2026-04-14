package sockets;

import models.Banco;
import models.Conta;
import notificacao.ServidorMulticast;
import service.ClienteService;
import service.ContaService;
import stream.ContaInputStream;
import stream.ContaOutputStream;

import java.net.*;
import java.io.*;

public class ServidorTCP {
    public static void main(String args[]) {

        new Thread(() -> {
            ServidorMulticast.anunciador();
        }).start();

        Banco banco = new Banco();
        File f = new File("contas.bin");

        if (f.exists()) {
            try (FileInputStream fis = new FileInputStream(f);
                 ContaInputStream cis = new ContaInputStream(fis)) {
                cis.read(banco);
                System.out.println("Dados carregados.");
            } catch (IOException e) {
                System.out.println("Erro ao ler arquivo, iniciando vazio.");
            }
        }

        ClienteService clienteService = new ClienteService(banco);
        ContaService contaService = new ContaService(banco);

        try {
            System.out.println("Servidor iniciado");
            int serverPort = 7897;
            ServerSocket listenSocket = new ServerSocket(serverPort);
            while (true) {
                Socket clientSocket = listenSocket.accept();
                System.out.println(clientSocket.getInetAddress());
                System.out.println("conexão estabelecida");
                new Connection(clientSocket, banco, clienteService, contaService);
            }
        } catch (IOException e) {
            System.out.println("Listen socket:" + e.getMessage());
        }
    }
}

class Connection extends Thread {
    ContaInputStream in;
    ContaOutputStream out;
    Socket clientSocket;
    Banco banco;
    ClienteService clienteService;
    ContaService contaService;

    public Connection(Socket aClientSocket, Banco banco, ClienteService clienteService, ContaService contaService) {
        try {
            this.clientSocket = aClientSocket;
            this.banco = banco;
            this.clienteService = clienteService;
            this.contaService = contaService;
            in = new ContaInputStream(clientSocket.getInputStream());
            this.start();
        } catch (IOException e) {
            System.out.println("Connection:" + e.getMessage());
        }
    }

    public void run() {
        try {

            ManipuladorCliente mc = new ManipuladorCliente(banco, clienteService, contaService, in, clientSocket.getOutputStream());

            while(true){
                Conta[] contasAtuais;
                int qtdAtual;

                synchronized (banco){
                    contasAtuais = banco.getContas().toArray(new Conta[0]);
                    qtdAtual = banco.getContas().size();
                }

                out = new ContaOutputStream(contasAtuais, qtdAtual, clientSocket.getOutputStream());

                mc.setOut(out);
                mc.processar();

                synchronized (banco) {
                    try (FileOutputStream fos = new FileOutputStream("contas.bin")) {
                        Conta[] contasAtualizadas = banco.getContas().toArray(new Conta[0]);
                        int qtd = banco.getContas().size();

                        ContaOutputStream outArquivo = new ContaOutputStream(contasAtualizadas, qtd, fos);
                        outArquivo.write(banco);
                        fos.flush();
                    } catch (IOException e) {
                        System.err.println("Falha ao persistir dados: " + e.getMessage());
                    }
                }

            }
        } catch (EOFException e) {
            System.out.println("Cliente finalizou a conexão.");
        } catch (SocketException e) {
            System.out.println("Conexão resetada pelo cliente (Broken Pipe).");
        } catch (IOException e) {
            System.out.println("Erro de IO: " + e.getMessage());
        } finally {
            try {
                clientSocket.close();
            } catch (IOException e) { }
        }

    }
}
