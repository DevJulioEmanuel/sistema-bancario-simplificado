package stream;

import models.Banco;
import models.Conta;
import models.ContaCorrente;
import models.ContaPoupanca;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class ContaOutputStream extends OutputStream {

    private DataOutputStream dos;
    private Conta[] contas;
    private int qtd;

    public ContaOutputStream(Conta[] c, int qtd, OutputStream os) {
        this.contas = c;
        this.qtd = qtd;
        this.dos = new DataOutputStream(os);
    }

    public void write(Banco banco) throws IOException {

        qtd = contas.length;

        dos.writeInt(qtd);

        for (Conta conta : contas) {
            if (conta != null) {
                int tipo = 0;
                double valor = 0;

                if (conta instanceof ContaCorrente cc){
                    tipo = 1;
                    valor = cc.getLimite();
                } else if (conta instanceof ContaPoupanca cp){
                    tipo = 2;
                    valor = cp.getRendimento();
                }

                byte[] tamanhoNomeTitularBytes = conta.getTitular().getNome().getBytes("UTF-8");
                byte[] tamanhoCPFBytes = conta.getTitular().getCpf().getBytes("UTF-8");
                byte[] tamanhoSenhaBytes = conta.getSenha().getBytes("UTF-8");
                int tamanhoPayload = Integer.BYTES + Integer.BYTES + tamanhoNomeTitularBytes.length + Integer.BYTES + tamanhoCPFBytes.length + Integer.BYTES + Double.BYTES + Integer.BYTES + tamanhoSenhaBytes.length + Double.BYTES;

                dos.writeInt(tipo);

                dos.writeInt(tamanhoPayload);

                dos.writeInt(conta.getTitular().getId());
                dos.writeInt(tamanhoNomeTitularBytes.length);
                dos.write(tamanhoNomeTitularBytes);
                dos.writeInt(tamanhoCPFBytes.length);
                dos.write(tamanhoCPFBytes);
                dos.writeInt(conta.getNumero());
                dos.writeDouble(conta.getSaldo());
                dos.writeInt(tamanhoSenhaBytes.length);
                dos.write(tamanhoSenhaBytes);
                dos.writeDouble(valor);

            }
        }

        dos.flush();
    }

    public void writeInt(int v) throws IOException {
        dos.writeInt(v);
        dos.flush();
    }

    public void writeDouble(double v) throws IOException {
        dos.writeDouble(v);
        dos.flush();
    }

    public void writeUTF(String v) throws IOException {
        dos.writeUTF(v);
        dos.flush();
    }

    @Override
    public void write(int b) throws IOException {
        // TODO Auto-generated method stub
        dos.write(b);
    }
}