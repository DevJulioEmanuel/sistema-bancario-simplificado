package models;

public class ContaPoupanca extends Conta{

    private double rendimento;
    private static int contadorNumero = 5000;

    public ContaPoupanca(Cliente titular) {
        super(contadorNumero++, 0, titular);
        this.rendimento = 0.005;
    }

    public ContaPoupanca(int numero, double saldo, Cliente titular, double rendimento) {
        super(numero, saldo, titular);
        this.rendimento = rendimento;

        if(numero >= contadorNumero){
            contadorNumero = numero + 1;
        }
    }

    public double getRendimento() {
        return rendimento;
    }

    public void setRendimento(double rendimento) {
        this.rendimento = rendimento;
    }
}
