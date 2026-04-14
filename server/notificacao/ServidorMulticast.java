package notificacao;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Random;

public class ServidorMulticast {

    public static void anunciador() {
        try {
            InetAddress addr = InetAddress.getByName("239.0.0.1");
            DatagramSocket ds = new DatagramSocket();

            Random random = new Random();

            String[] frases = {
                    "SEGURANÇA: O banco nunca solicita tokens ou senhas por telefone.",
                    "OFERTA: Antecipe seu 13º salário com as menores taxas do mercado.",
                    "INVESTIMENTO: CDB com liquidez diária é a melhor opção para sua reserva.",
                    "TRIBUTAÇÃO: Lembre-se que a Conta Corrente possui taxas sobre movimentação.",
                    "POUPANÇA: Guarde seus rendimentos com a segurança da maior instituição da rede.",
                    "CUIDADO: Ao utilizar o terminal, certifique-se de que não há ninguém observando sua senha.",
                    "LIMITE: Precisa de mais crédito? Solicite uma análise de perfil no menu principal.",
                    "EXTRATO: Mantenha o controle das suas finanças consultando seu histórico semanalmente.",
                    "TRANSFERÊNCIA: Verifique sempre o nome do titular antes de confirmar o envio.",
                    "DICA: Diversifique seus investimentos entre Poupança e Renda Fixa.",
                    "ALERTA: Identificou uma movimentação estranha? Bloqueie sua conta imediatamente.",
                    "CONTA PJ: Soluções exclusivas para o crescimento da sua empresa.",
                    "SEGURO: Proteja seu patrimônio com nosso seguro residencial simplificado.",
                    "ATUALIZAÇÃO: Mantenha seus dados cadastrais em dia para receber novos benefícios.",
                    "CASHBACK: Ganhe parte do seu dinheiro de volta em compras com parceiros selecionados.",
                    "PREVIDÊNCIA: Planeje sua aposentadoria com aportes a partir de R$ 50,00.",
                    "SISTEMA: Operações de transferência entre contas do mesmo banco são gratuitas.",
                    "CARTÃO: Ative a função de aproximação para pagamentos mais ágeis no dia a dia.",
                    "CONSÓRCIO: A maneira mais planejada de conquistar sua casa ou veículo novo.",
                    "AVISO: O saldo da sua Conta Poupança é atualizado no dia do aniversário da conta.",
                    "PAGAMENTOS: Evite filas pagando seus boletos diretamente pelo nosso terminal.",
                    "DICA FINANCEIRA: Gastar menos do que ganha é o primeiro passo para o sucesso.",
                    "CRÉDITO RURAL: Linhas de financiamento especiais para o pequeno produtor.",
                    "CARTA DE CRÉDITO: Crédito imobiliário pré-aprovado para clientes com conta ativa.",
                    "VANTAGEM: Clientes com saldo médio elevado possuem isenção de taxas administrativas.",
                    "CÂMBIO: Vai viajar? Compre moeda estrangeira com a cotação comercial do dia.",
                    "SUGESTÃO: Utilize o agendamento de transferências para não esquecer seus compromissos.",
                    "FRAUDE: Desconfie de ofertas excessivamente vantajosas enviadas por SMS.",
                    "SUPORTE: Nossa central de atendimento está disponível 24h para emergências.",
                    "ENCERRAMENTO: Por segurança, clique em 'Sair' ao finalizar suas consultas."
            };

            while (true) {
                int indice = random.nextInt(frases.length);
                String mensagem = frases[indice];
                byte[] b = mensagem.getBytes("UTF-8");
                DatagramPacket pkg = new DatagramPacket(b, b.length, addr, 12347);

                ds.send(pkg);
                System.out.println("[SERVIDOR] " + mensagem);

                Thread.sleep(60000);
            }

        } catch (Exception e) {
            System.out.println("Erro no servidor: " + e.getMessage());
            e.printStackTrace();
        }
    }
}