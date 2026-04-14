import models.*;
import stream.ContaInputStream;
import stream.ContaOutputStream;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class TesteStreams {
    public static void main(String[] args) throws IOException{
        Conta[] contas = new Conta[1];
        Banco banco = new Banco();

        try {
            FileInputStream fis = new FileInputStream("contas.bin");
            ContaInputStream cis = new ContaInputStream(fis);
            cis.read(banco);
            for (Cliente c : banco.getClientes()) {
                if (c != null) {
                    System.out.println("ID: " + c.getId());
                    System.out.println("Titular: " + c.getNome());
                    System.out.println("CPF: " + c.getCpf());
//                    System.out.println("Conta Recuperada: " + c.getNumero());
//                    System.out.println("Saldo: R$ " + c.getSaldo());
//                    if(c instanceof ContaCorrente cc){
//                        System.out.println("Limite: R$ " + cc.getLimite());
//                    } else if (c instanceof ContaPoupanca cp){
//                        System.out.println("Taxa rendimento: " + cp.getRendimento());
//                    }
                    System.out.println("-------------------------");
                }
            }
            cis.close();

//            models.Conta[] array = banco.getContas().toArray(new models.Conta[0]);
//
//            ContaOutputStream cos = new ContaOutputStream(
//                    array,
//                    array.length,
//                    System.out
//            );
//            cos.write(banco);
//
//            Cliente c = new Cliente("Emanuel", "6698766666");
//            banco.getContas().add(new ContaCorrente(c, "teste"));
//            banco.getContas().add(new ContaPoupanca(c, "teste"));
//
//            models.Conta[] array1 = banco.getContas().toArray(new models.Conta[0]);
//
//            FileOutputStream fos = new FileOutputStream("contas.bin");
//            ContaOutputStream cos1 = new ContaOutputStream(array1, array1.length, fos);
//            cos1.write(banco);
//            cos1.close();
//
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Erro no processo: " + e.getMessage());
        }
    }
}