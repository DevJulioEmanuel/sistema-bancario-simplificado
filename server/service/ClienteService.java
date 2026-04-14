package service;

import models.Banco;
import models.Cliente;
import models.Conta;

import java.util.ArrayList;
import java.util.List;

public class ClienteService {

    private final Banco banco;

    public ClienteService(Banco banco) {
        this.banco = banco;
    }

    public synchronized Cliente salvarOuObter(String nome, String cpf){
        Cliente existente = buscarPorCpf(cpf);
        if(existente != null){
            return existente;
        }

        Cliente novo = new Cliente(nome, cpf);
        this.banco.getClientes().add(novo);
        return novo;
    }

    public synchronized Cliente buscarPorCpf(String cpf){
        for(Cliente c: banco.getClientes()){
            if(c.getCpf().equals(cpf)){
                return c;
            }
        }

        return null;
    }

    public synchronized List<Conta> listarContas(String cpf){
        List<Conta> contas = new ArrayList<>();
        for(Conta c: banco.getContas()){
            if(c.getTitular().getCpf().equals(cpf)){
                contas.add(c);
            }
        }

        return contas;
    }
}
