# arquitetura-e-organizacao-de-computadores---2025-2
Jogo de Queimada (Dodgeball) desenvolvido em Assembly para o Processador ICMC (Arquitetura RISC de 16 bits).
# 🕹️ SUPER QUEIMADA (DODGEBALL) - PURE ARCADE EDITION

**Aluno:** Laura Nordi Zambom  
**Disciplina:** Arquitetura e Organização de Computadores - 2025/2

---

## 🎥 Demonstração do Jogo

Abaixo, você pode conferir o vídeo demonstrando a execução do jogo no simulador, desde a tela de menu até o fim de uma partida.

![Demonstração do Jogo](demonstracao.mov)

> **Nota:** Caso o vídeo não carregue acima, você pode acessá-lo diretamente na pasta do repositório: `demonstracao.mov`.

---

## 🎯 Sobre o Jogo

O **Super Queimada** é um jogo de ação arcade em que o jogador deve eliminar o oponente lançando uma bola, enquanto desvia dos ataques inimigos. O projeto foi implementado inteiramente em **Assembly** para a arquitetura de 16 bits do ICMC.

### 🎮 Controles
| Tecla | Ação |
| :--- | :--- |
| **W** | Move o jogador (P) para **CIMA** |
| **S** | Move o jogador (P) para **BAIXO** |
| **ESPAÇO** | Lança a bola (quando estiver com a posse) |
| **Y** | Reinicia o jogo (na tela final) |
| **N** | Encerra o programa (na tela final) |

---

## 🧠 Lógica e Implementação

O software foi estruturado de forma modular, utilizando sub-rotinas e interrupções lógicas controladas por *timers*.

### 1. Inteligência Artificial (IA)
O oponente (`E`) possui dois estados principais gerenciados pela rotina `LogicEnemy_Tracking`:
* **Modo Defesa:** Realiza um movimento de "ping-pong" constante para cobrir a maior área possível da quadra enquanto o jogador ataca.
* **Modo Ataque:** Rastreia a posição vertical do jogador (`PlayerY`) e se alinha perfeitamente antes de realizar o disparo.

### 2. Física e Colisões
A rotina `LogicBall_Physics` controla o deslocamento da bola no eixo X e verifica a cada *tick* se houve intersecção com as coordenadas Y dos personagens. O sistema de **Turnover** garante que, se a bola sair da quadra sem atingir o alvo, a posse mude automaticamente para o adversário.

### 3. Sistema de Timers
Para evitar que o jogo rode rápido demais, foram implementados contadores de *cooldown* (`TimerPlayer`, `TimerEnemy`, `TimerBall`). Isso permite que o movimento do jogador, a reação da IA e a velocidade da bola sejam ajustados de forma independente.

---

## 📁 Estrutura do Repositório

| Arquivo/Pasta | Descrição |
| :--- | :--- |
| **`JOGO.ASM`** | Código-fonte principal com toda a lógica do jogo comentada. |
| **`CHARMAP.MIF`** | Tabela de caracteres utilizada para a renderização gráfica. |
| **`demonstracao.mov`** | Vídeo de demonstração da jogabilidade. |
| **`simulador/`** | Pasta contendo os arquivos `.c` e `.h` do Simple Simulator. |
| **`.gitignore`** | Filtro para evitar o upload de arquivos binários e temporários. |

---

## 🚀 Como Executar

1.  Compile o arquivo `JOGO.ASM` utilizando o **Montador (Assembler)** do ICMC.
2.  Carregue o arquivo `.mif` gerado no **Simulador**.
3.  Certifique-se de que o `CHARMAP.MIF` esteja na mesma pasta do simulador para a correta exibição dos caracteres.
4.  No simulador, inicie a execução e escolha a dificuldade (1, 2 ou 3).
