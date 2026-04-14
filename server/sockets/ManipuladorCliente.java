package sockets;

import models.*;
import service.ClienteService;
import service.ContaService;
import stream.ContaInputStream;
import stream.ContaOutputStream;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

public class ManipuladorCliente {

    private final Banco banco;
    private final ClienteService clienteService;
    private final ContaService contaService;
    private final ContaInputStream in;
    private ContaOutputStream out;
    private final OutputStream rawOut;

    public ManipuladorCliente(Banco banco, ClienteService clienteService, ContaService contaService, ContaInputStream in, OutputStream rawOut) {
        this.banco = banco;
        this.clienteService = clienteService;
        this.contaService = contaService;
        this.in = in;
        this.rawOut = rawOut;
    }

    public void processar() throws IOException {
        int op = in.readInt();

        switch (op){

            // Cadastro
            case 1:
                try {
                    String nome = in.readUTF();
                    String cpf = in.readUTF();
                    String senha = in.readUTF();
                    int tipo = in.readInt();

                    Cliente novo = new Cliente(nome, cpf);

                    clienteService.cadastrar(novo);

                    contaService.abrirConta(novo, senha, tipo);

                    out.writeInt(0);
                } catch (IllegalArgumentException e){
                    out.writeInt(-1);
                }
                break;

            // Login
            case 2:
                try {
                    String cpf = in.readUTF();
                    String senha = in.readUTF();
                    int tipo = in.readInt();

                    List<Conta> contas = clienteService.listarContas(cpf);
                    Conta encontada = null;

                    for (Conta c: contas){
                        if(tipo == 1 && c instanceof ContaCorrente){
                            if(c.getSenha().equals(senha)){
                                encontada = c;
                                break;
                            }
                        } else if (tipo == 2 && c instanceof ContaPoupanca) {
                            if(c.getSenha().equals(senha)){
                                encontada = c;
                                break;
                            }
                        }
                    }

                    if(encontada != null){
                        out.writeInt(0);
                        Conta[] conta = {encontada};
                        ContaOutputStream login = new ContaOutputStream(conta, 1, rawOut);
                        login.write(banco);
                    } else {
                        out.writeInt(-1);
                    }

                } catch (IllegalArgumentException e){
                    out.writeInt(-1);
                }

                break;

            // Saque
            case 3:
                int numeroSaque = in.readInt();
                double valorSaque = in.readDouble();

                Conta contaSaque = contaService.buscarConta(numeroSaque);

                if(contaSaque == null){
                    out.writeInt(-1);
                } else {
                    if (contaService.sacar(contaSaque, valorSaque)){
                        out.writeInt(0);
                    } else {
                        out.writeInt(-2);
                    }
                }

                break;

            // Deposito
            case 4:
                int numeroDeposito = in.readInt();
                double valorDeposito = in.readDouble();

                Conta contaDeposito = contaService.buscarConta(numeroDeposito);

                if(contaDeposito == null){
                    out.writeInt(-1);
                } else {
                    if (contaService.depositar(contaDeposito, valorDeposito)){
                        out.writeInt(0);
                    } else {
                        out.writeInt(-2);
                    }
                }
                break;

            // Transferir
            case 5:
                int numOrigem = in.readInt();
                int numDestino = in.readInt();
                double valor = in.readDouble();

                Conta origem = contaService.buscarConta(numOrigem);
                if(origem == null){
                    out.writeInt(-1);
                    break;
                }

                Conta destino = contaService.buscarConta(numDestino);
                if(destino == null){
                    out.writeInt(-2);
                    break;
                }

                if(contaService.transferir(origem, destino, valor)){
                    out.writeInt(0);
                    out.writeUTF(destino.getTitular().getNome());
                } else {
                    out.writeInt(-3);
                }

                break;

            // Pagar
            case 6:
                int numContaPag = in.readInt();
                double valorPag = in.readDouble();
                String descricao = in.readUTF();

                Conta conta = contaService.buscarConta(numContaPag);
                if(conta == null){
                    out.writeInt(-1);
                    break;
                }

                if(contaService.pagar(conta, valorPag, descricao)){
                    out.writeInt(0);
                } else {
                    out.writeInt(-2);
                }

                break;

            // Projetar rendimento
            case 7:
                int numeroRendimento = in.readInt();
                int meses = in.readInt();

                Conta contaRendimento = contaService.buscarConta(numeroRendimento);

                if(contaRendimento instanceof ContaPoupanca cp){
                    double resultado = contaService.projetarRendimento(cp, meses);
                    out.writeInt(0);
                    out.writeDouble(resultado);
                } else {
                    out.writeInt(-1);
                }

                break;

            // Extrato
            case 8:
                    int numContaExtrato = in.readInt();

                    Conta contaAlvo = contaService.buscarConta(numContaExtrato);

                    if (contaAlvo == null) {
                        out.writeInt(-1);
                    } else {
                        List<String> historico = contaService.consultarExtrato(numContaExtrato);

                        out.writeInt(0);
                        out.writeInt(historico.size());

                        for (String linha : historico) {
                            out.writeUTF(linha);
                        }
                    }

                break;
        }

    }

    public void setOut(ContaOutputStream out) {
        this.out = out;
    }

}
