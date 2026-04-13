package stream;

import models.*;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ContaInputStream extends InputStream {

    private DataInputStream dis;

    public ContaInputStream(InputStream is) {
        this.dis = new DataInputStream(is);
    }

    public void read(Banco banco) throws IOException{
        synchronized (banco){

            int qtd = dis.readInt();

            for(int i = 0; i < qtd; i++) {
                int tipo = dis.readInt();
                int payload = dis.readInt();
                int id = dis.readInt();

                int tamanhoNome = dis.readInt();
                byte[] b = new byte[tamanhoNome];
                dis.readFully(b);
                String nome = new String(b, "UTF-8");

                int tamanhoCPF = dis.readInt();
                byte[] c = new byte[tamanhoCPF];
                dis.readFully(c);
                String cpf = new String(c, "UTF-8");

                int tamanhoSenha = dis.readInt();
                byte[] s = new byte[tamanhoSenha];
                dis.readFully(b);
                String senha = new String(b, "UTF-8");

                int numero = dis.readInt();
                double saldo = dis.readDouble();
                double valor = dis.readDouble();

                Cliente cliente = null;
                for (Cliente cli : banco.getClientes()) {
                    if (cli.getCpf().equals(cpf)) {
                        cliente = cli;
                    }
                }

                if (cliente == null) {
                    cliente = new Cliente(nome, cpf);
                    banco.getClientes().add(cliente);
                }

                if (tipo == 1) {
                    banco.getContas().add(new ContaCorrente(numero, saldo, cliente, valor, senha));
                } else if (tipo == 2) {
                    banco.getContas().add(new ContaPoupanca(numero, saldo, cliente, valor, senha));
                }
            }
        }
    }

    public int readInt() throws IOException {
        return dis.readInt();
    }

    public double readDouble() throws IOException {
        return dis.readDouble();
    }

    public String readUTF() throws IOException {
        return dis.readUTF();
    }

    @Override
    public int read() throws IOException {
        // TODO Auto-generated method stub
        return 0;
    }

}