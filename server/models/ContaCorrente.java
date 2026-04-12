package models;

import interfaces.Tributavel;

public class ContaCorrente extends Conta implements Tributavel {

    private double limite;
    private static int contadorNumero = 1000;

    public ContaCorrente(Cliente titular) {
        super(contadorNumero++, 0, titular);
        this.limite = 1200;
    }

    public ContaCorrente(int numero, double saldo, Cliente titular, double limite) {
        super(numero, saldo, titular);
        this.limite = limite;

        if (numero >= contadorNumero) {
            contadorNumero = numero + 1;
        }
    }

    public double getLimite() {
        return limite;
    }

    public void setLimite(double limite) {
        this.limite = limite;
    }

    @Override
    public double calcularImposto() {
        return 0;
    }

}
