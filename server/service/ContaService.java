package service;

import models.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContaService {

    private final Banco banco;
    private final Map<Integer, List<String>> repositorioExtratos = new HashMap<>();

    private void registrar(int numeroConta, String mensagem) {
        repositorioExtratos
                .computeIfAbsent(numeroConta, k -> new ArrayList<>())
                .add(mensagem);
    }

    public List<String> consultarExtrato(int numeroConta) {
        return repositorioExtratos.getOrDefault(numeroConta, new ArrayList<>());
    }

    public ContaService(Banco banco) {
        this.banco = banco;
    }

    public synchronized boolean abrirConta(Cliente cliente, String senha, int tipo){
        Conta nova;

        if(tipo == 1){
            nova = new ContaCorrente(cliente, senha);
        } else{
            nova = new ContaPoupanca(cliente, senha);
        }

        synchronized (banco) {
            banco.getContas().add(nova);
        }

        return true;
    }

    public synchronized boolean sacar(Conta conta, double valor){
        if(valor >= 0 && conta.getSaldo() >= valor){
            conta.setSaldo(conta.getSaldo() - valor);
            return true;
        }

        return false;
    }

    public synchronized boolean depositar(Conta conta, double valor){
        if(valor > 0){
            conta.setSaldo(conta.getSaldo() + valor);
            return true;
        }

        return false;
    }

    public synchronized boolean transferir(Conta origem, Conta destino, double valor){
        double imposto = 0;

        if (origem instanceof ContaCorrente cc) {
            imposto = cc.calcularImposto();
        }

        double totalADebitar = valor + imposto;

        if(sacar(origem, totalADebitar)){
            depositar(destino, valor);

            registrar(origem.getNumero(), "Transferência enviada: -R$ " + valor + " (Imposto: R$ " + imposto + ")");
            registrar(destino.getNumero(), "Transferência recebida: +R$ " + valor + " de " + origem.getTitular().getNome());

            return true;
        }

        return false;
    }

    public synchronized boolean pagar(Conta conta, double valor, String descricao){
        if(conta instanceof ContaCorrente cc){
            if (sacar(cc, valor)){
                registrar(conta.getNumero(), "Pagamento: " + descricao + " | Valor: -R$ " + valor);

                return true;
            }
        } else {
            return false;
        }

        return false;
    }


    public synchronized double projetarRendimento(Conta conta, int meses){
        if(!(conta instanceof ContaPoupanca)){
            return -1;
        }

        ContaPoupanca cp = (ContaPoupanca) conta;
        double taxa = cp.getRendimento();
        double saldo = cp.getSaldo();

        return saldo * Math.pow((1 + taxa), meses);
    }

    public synchronized Conta buscarConta(int numero){
        for(Conta c: banco.getContas()){
            if(c.getNumero() == numero){
                return c;
            }
        }

        return null;
    }
}