package stream;

import models.*;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ContaInputStream extends InputStream {

    private InputStream is;

    public ContaInputStream(InputStream is) {
        this.is = is;
    }

    public void read(Banco banco) throws IOException{
        DataInputStream dis = new DataInputStream(is);

        int qtd = dis.readInt();

        for(int i = 0; i < qtd; i++){
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

            int numero = dis.readInt();
            double saldo = dis.readDouble();
            double valor = dis.readDouble();

            Cliente titular = new Cliente(id, nome, cpf);

            if(!banco.getClientes().contains(titular)){
                banco.getClientes().add(titular);
            }

            if (tipo == 1){
                banco.getContas().add(new ContaCorrente(numero, saldo, titular, valor));
            } else if (tipo == 2){
                banco.getContas().add(new ContaPoupanca(numero, saldo, titular, valor));
            }
        }
    }

    @Override
    public int read() throws IOException {
        // TODO Auto-generated method stub
        return 0;
    }

}