package stream;

import models.Banco;
import models.Conta;
import models.ContaCorrente;
import models.ContaPoupanca;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class ContaOutputStream extends OutputStream {

    private OutputStream op;
    private Conta[] contas;
    private int qtd;

    public ContaOutputStream(Conta[] c, int qtd, OutputStream os) {
        this.contas = c;
        this.qtd = qtd;
        this.op = os;
    }

    public void write(Banco banco) throws IOException {

        DataOutputStream opLocal = new DataOutputStream(op);

        contas = banco.getContas().toArray(new Conta[0]);
        qtd = contas.length;

        opLocal.writeInt(qtd);

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
                int tamanhoPayload = Integer.BYTES + Integer.BYTES + tamanhoNomeTitularBytes.length + Integer.BYTES + tamanhoCPFBytes.length + Integer.BYTES + Double.BYTES + Double.BYTES;

                opLocal.writeInt(tipo);

                opLocal.writeInt(tamanhoPayload);

                opLocal.writeInt(conta.getTitular().getId());
                opLocal.writeInt(tamanhoNomeTitularBytes.length);
                opLocal.write(tamanhoNomeTitularBytes);
                opLocal.writeInt(tamanhoCPFBytes.length);
                opLocal.write(tamanhoCPFBytes);
                opLocal.writeInt(conta.getNumero());
                opLocal.writeDouble(conta.getSaldo());
                opLocal.writeDouble(valor);

            }
        }

        opLocal.flush();
    }

    @Override
    public void write(int b) throws IOException {
        // TODO Auto-generated method stub
        op.write(b);
    }
}