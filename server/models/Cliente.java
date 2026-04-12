package models;

public class Cliente {

    private int id;
    private String nome;
    private String cpf;
    private static int contadorId = 1000;

    public Cliente(String nome, String cpf) {
        this.id = contadorId++;
        this.nome = nome;
        this.cpf = cpf;
    }

    public Cliente(int idRecuperado, String nome, String cpf) {
        this.id = idRecuperado;
        this.nome = nome;
        this.cpf = cpf;

        if(idRecuperado >= contadorId){
            contadorId = idRecuperado + 1;
        }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }
}
