; ==============================================================================
; JOGO: SUPER QUEIMADA (DODGEBALL) - PURE ARCADE EDITION
; ==============================================================================

jmp start_program

; ==============================================================================
; VARIÁVEIS DO JOGO
; ==============================================================================
; Posicoes
PlayerY:    var #1      
EnemyY:     var #1      
BallX:      var #1      
BallY:      var #1      
BallActive: var #1      ; 0=Mao, 1=Voando
BallDir:    var #1      ; 0=Player Chutou, 1=NPC Chutou
BallSpeed:  var #1      ; Velocidade atual da bola

; Timers (Cooldowns)
TimerPlayer: var #1     
TimerEnemy:  var #1     
TimerBall:   var #1     

; Configs
SpeedEnemy:  var #1     
EnemyPingPongDir: var #1 ; 0=subindo, 1=descendo

; ==============================================================================
; CONSTANTES - TECLAS
; ==============================================================================
KEY_W:      var #1
static KEY_W, #'w'
KEY_S:      var #1
static KEY_S, #'s'
KEY_SPACE:  var #1
static KEY_SPACE, #32
KEY_Y:      var #1
static KEY_Y, #'y'
KEY_N:      var #1
static KEY_N, #'n'

; ==============================================================================
; CONSTANTES - VELOCIDADES
; ==============================================================================
SPEED_BALL:   var #1
static SPEED_BALL, #16   ; Bola Player

SPEED_BALL_ENEMY: var #1
static SPEED_BALL_ENEMY, #2   ; Bola NPC (5x mais rápida)

SPEED_PLAYER: var #1
static SPEED_PLAYER, #166 ; Player 3x mais rápido

; ==============================================================================
; STRINGS - INTERFACE DO JOGO
; ==============================================================================
str_title:   string "=== CAMPEONATO DE QUEIMADA ==="
str_diff:    string "ESCOLHA SEU OPONENTE: 1-NOVATO 2-AMADOR 3-PRO"

str_turn_p:  string "SEU SAQUE! ATAQUE!"
str_turn_e:  string "CUIDADO! DEFENDA-SE!"

str_win:     string "VITORIA! VOCE E O REI DA QUADRA!"
str_lose:    string "VOCE FOI ELIMINADO!"
str_retry:   string "JOGAR NOVAMENTE? (y/n)"

str_thanks:  string "OBRIGADA POR JOGAR :)"

; ==============================================================================
; SETUP - INICIALIZAÇÃO DO PROGRAMA
; ==============================================================================
start_program:
    jmp menu_screen

; ==============================================================================
; MENU PRINCIPAL - Seleção de dificuldade
; ==============================================================================
menu_screen:
    call ClearScreen
    loadn r0, #405
    loadn r1, #str_title
    loadn r2, #3840 ; Branco
    call PrintStringColor
    
    loadn r0, #520
    loadn r1, #str_diff
    call PrintStringColor

wait_diff:
    inchar r0
    loadn r1, #'1'
    cmp r0, r1
    jeq set_easy
    loadn r1, #'2'
    cmp r0, r1
    jeq set_med
    loadn r1, #'3'
    cmp r0, r1
    jeq set_hard
    jmp wait_diff

set_easy:
    loadn r0, #200 
    store SpeedEnemy, r0
    jmp init_game
set_med:
    loadn r0, #100 
    store SpeedEnemy, r0
    jmp init_game
set_hard:
    loadn r0, #50 
    store SpeedEnemy, r0
    jmp init_game

; ==============================================================================
; INICIALIZAÇÃO DO JOGO
; ==============================================================================
init_game:
    ; Setup Visual
    call ClearScreen
    call DrawCourtLine
    
    ; Mensagem Inicial
    loadn r0, #40
    loadn r1, #str_turn_p
    loadn r2, #512 ; Verde
    call PrintStringColor

    ; Posicoes
    loadn r0, #15
    store PlayerY, r0
    store EnemyY, r0
    
    ; Bola começa com Player
    loadn r0, #0
    store BallActive, r0
    store BallDir, r0 
    
    ; Reset Timers
    store TimerEnemy, r0
    store TimerBall, r0
    store TimerPlayer, r0
    
    ; Inicializa direção do ping pong
    store EnemyPingPongDir, r0

    call Delay1Sec

; ==============================================================================
; LOOP PRINCIPAL DO JOGO
; ==============================================================================
game_loop:
    call ClearOldState
    call UpdateTimers
    call InputPlayer      
    call LogicEnemy_Tracking 
    call LogicBall_Physics 
    call DrawEntities
    call DelayTick
    
    jmp game_loop

; ==============================================================================
; LÓGICA - ATUALIZAÇÃO DE TIMERS
; ==============================================================================
UpdateTimers:
    load r0, TimerPlayer
    loadn r1, #0
    cmp r0, r1
    jeq skip_tp
    dec r0
    store TimerPlayer, r0
skip_tp:
    load r0, TimerEnemy
    cmp r0, r1
    jeq skip_te
    dec r0
    store TimerEnemy, r0
skip_te:
    load r0, TimerBall
    cmp r0, r1
    jeq skip_tb
    dec r0
    store TimerBall, r0
skip_tb:
    rts

; ==============================================================================
; LÓGICA - FÍSICA DA BOLA
; ==============================================================================
LogicBall_Physics:
    load r0, TimerBall
    loadn r1, #0
    cmp r0, r1
    jgr ret_ball
    
    load r0, BallSpeed
    store TimerBall, r0
    
    load r0, BallActive
    cmp r0, r1
    jeq ret_ball
    
    load r0, BallDir
    cmp r0, r1
    jeq move_ball_right
    
    ; --- Esquerda (Vindo p/ Player) ---
move_ball_left:
    load r0, BallX
    dec r0
    store BallX, r0
    
    loadn r1, #1
    cmp r0, r1
    jeq check_hit_player
    
    loadn r1, #0
    cmp r0, r1
    jle turnover_to_player
    rts

check_hit_player:
    load r0, BallY
    load r1, PlayerY
    cmp r0, r1
    jne turnover_to_player
    jmp game_over_lose

move_ball_right:
    load r0, BallX
    inc r0
    store BallX, r0
    
    loadn r1, #38
    cmp r0, r1
    jeq check_hit_enemy
    
    loadn r1, #40
    cmp r0, r1
    jgr turnover_to_enemy
    rts

check_hit_enemy:
    load r0, BallY
    load r1, EnemyY
    cmp r0, r1
    jne turnover_to_enemy
    jmp round_win

turnover_to_player:
    loadn r0, #0
    store BallActive, r0
    store BallDir, r0 
    
    call ClearMessageArea
    loadn r0, #40
    loadn r1, #str_turn_p
    loadn r2, #512
    call PrintStringColor
    rts

turnover_to_enemy:
    loadn r0, #0
    store BallActive, r0
    loadn r0, #1
    store BallDir, r0 
    
    call ClearMessageArea
    loadn r0, #40
    loadn r1, #str_turn_e
    loadn r2, #2304
    call PrintStringColor
    rts

round_win:
    jmp win_game_screen

ret_ball:
    rts

; ==============================================================================
; LÓGICA - IA DO NPC
; ==============================================================================
LogicEnemy_Tracking:
    load r0, TimerEnemy
    loadn r1, #0
    cmp r0, r1
    jgr ret_npc
    
    load r0, SpeedEnemy
    store TimerEnemy, r0
    
    load r0, BallDir
    loadn r1, #1
    cmp r0, r1
    jeq npc_attack_mode
    
    ; --- MODO DEFESA - Ping Pong ---
    load r0, EnemyPingPongDir
    loadn r1, #0
    cmp r0, r1
    jeq npc_def_subindo
    
    load r0, EnemyY
    loadn r1, #29
    cmp r0, r1
    jgr npc_def_change_to_subindo
    
    inc r0
    store EnemyY, r0
    rts

npc_def_change_to_subindo:
    loadn r0, #0
    store EnemyPingPongDir, r0
    load r0, EnemyY
    dec r0
    store EnemyY, r0
    rts

npc_def_subindo:
    load r0, EnemyY
    loadn r1, #4
    cmp r0, r1
    jle npc_def_change_to_descendo
    
    dec r0
    store EnemyY, r0
    rts

npc_def_change_to_descendo:
    loadn r0, #1
    store EnemyPingPongDir, r0
    load r0, EnemyY
    inc r0
    store EnemyY, r0
    rts

; --- MODO ATAQUE ---
npc_attack_mode:
    load r0, BallActive
    loadn r1, #1
    cmp r0, r1
    jeq npc_attack_follow
    
    load r0, EnemyY
    load r1, PlayerY
    cmp r0, r1
    jeq npc_shoot_attack
    
    cmp r0, r1
    jgr npc_attack_follow_up
    jmp npc_attack_follow_down

npc_shoot_attack:
    loadn r0, #1
    store BallActive, r0
    load r0, EnemyY
    store BallY, r0
    loadn r0, #38
    store BallX, r0
    load r0, SPEED_BALL_ENEMY
    store BallSpeed, r0
    rts

npc_attack_follow:
    load r0, EnemyY
    load r1, PlayerY
    cmp r0, r1
    jeq ret_npc
    cmp r0, r1
    jgr npc_attack_follow_up
    jmp npc_attack_follow_down

npc_attack_follow_up:
    load r0, EnemyY
    loadn r1, #4
    cmp r0, r1
    jle ret_npc
    dec r0
    store EnemyY, r0
    rts

npc_attack_follow_down:
    load r0, EnemyY
    loadn r1, #29
    cmp r0, r1
    jgr ret_npc
    inc r0
    store EnemyY, r0
    rts

ret_npc:
    rts

; ==============================================================================
; INPUT - CONTROLE DO PLAYER
; ==============================================================================
InputPlayer:
    load r0, TimerPlayer
    loadn r1, #0
    cmp r0, r1
    jgr ret_inp

    inchar r0
    load r1, KEY_W
    cmp r0, r1
    jeq p_up
    load r1, KEY_S
    cmp r0, r1
    jeq p_down
    load r1, KEY_SPACE
    cmp r0, r1
    jeq p_shoot
    rts

p_up:
    load r0, PlayerY
    loadn r1, #4
    cmp r0, r1
    jle ret_inp
    dec r0
    store PlayerY, r0
    call reset_p_timer
    rts

p_down:
    load r0, PlayerY
    loadn r1, #29
    cmp r0, r1
    jgr ret_inp
    inc r0
    store PlayerY, r0
    call reset_p_timer
    rts

p_shoot:
    load r0, BallDir
    loadn r1, #0
    cmp r0, r1
    jne ret_inp
    load r0, BallActive
    cmp r0, r1
    jne ret_inp
    
    loadn r0, #1
    store BallActive, r0
    load r0, PlayerY
    store BallY, r0
    loadn r0, #2
    store BallX, r0
    loadn r0, #0
    store BallDir, r0
    load r0, SPEED_BALL
    store BallSpeed, r0
    call reset_p_timer
    rts

reset_p_timer:
    load r0, SPEED_PLAYER
    store TimerPlayer, r0
ret_inp:
    rts

; ==============================================================================
; GRÁFICOS - RENDERIZAÇÃO
; ==============================================================================
DrawEntities:
    push r0
    push r1
    push r2
    push r3
    
    ; Player
    load r0, PlayerY
    loadn r1, #1
    loadn r2, #'P'
    loadn r3, #512
    add r2, r2, r3
    call PlotXY
    
    ; Enemy
    load r0, EnemyY
    loadn r1, #38
    loadn r2, #'E'
    loadn r3, #2304
    add r2, r2, r3
    call PlotXY
    
    ; Bola
    load r0, BallActive
    loadn r1, #0
    cmp r0, r1
    jeq de_skip_ball
    load r0, BallY
    load r1, BallX
    loadn r2, #'O'
    loadn r3, #2816
    add r2, r2, r3
    call PlotXY
    
de_skip_ball:
    ; Redesenha rede (y=4 a 29, x=20)
    loadn r0, #4
de_net_loop:
    loadn r1, #20
    loadn r2, #'|'
    loadn r3, #3840
    add r2, r2, r3
    call PlotXY
    inc r0
    loadn r3, #30
    cmp r0, r3
    jne de_net_loop
    
    pop r3
    pop r2
    pop r1
    pop r0
    rts

ClearOldState:
    push r0
    push r1
    push r2
    
    load r0, PlayerY
    loadn r1, #1
    loadn r2, #' '
    call PlotXY
    
    load r0, EnemyY
    loadn r1, #38
    call PlotXY
    
    load r3, BallActive
    loadn r4, #1
    cmp r3, r4
    jne cos_out
    load r0, BallY
    load r1, BallX
    call PlotXY
cos_out:
    pop r2
    pop r1
    pop r0
    rts

DrawCourtLine:
    push r0
    push r1
    push r2
    push r3
    loadn r0, #4
    loadn r1, #20
    loadn r2, #'|'
    loadn r3, #3840
    add r2, r2, r3
dcl_loop:
    call PlotXY
    inc r0
    loadn r3, #30
    cmp r0, r3
    jne dcl_loop
    pop r3
    pop r2
    pop r1
    pop r0
    rts

PlotXY:
    push r0
    push r1
    push r3
    loadn r3, #40
    mul r0, r0, r3
    add r0, r0, r1
    outchar r2, r0
    pop r3
    pop r1
    pop r0
    rts

ClearMessageArea:
    push r0
    push r1
    push r2
    loadn r0, #40
    loadn r1, #' '
    loadn r2, #40
cma_loop:
    outchar r1, r0
    inc r0
    dec r2
    jnz cma_loop
    pop r2
    pop r1
    pop r0
    rts

; ==============================================================================
; UTILIDADES
; ==============================================================================
ClearScreen:
    push r0
    push r1
    push r2
    loadn r0, #0
    loadn r1, #1200
    loadn r2, #' '
cl_loop:
    outchar r2, r0
    inc r0
    cmp r0, r1
    jne cl_loop
    pop r2
    pop r1
    pop r0
    rts

PrintStringColor:
    push r3
    push r4
ps_loop:
    loadi r3, r1
    loadn r4, #0
    cmp r3, r4
    jeq ps_end
    add r3, r3, r2
    outchar r3, r0
    inc r0
    inc r1
    jmp ps_loop
ps_end:
    pop r4
    pop r3
    rts

DelayTick:
    push r0
    loadn r0, #200
dt_loop:
    dec r0
    jnz dt_loop
    pop r0
    rts

Delay1Sec:
    push r0
    push r1
    loadn r1, #25
d1_outer:
    loadn r0, #10000
d1_inner:
    dec r0
    jnz d1_inner
    dec r1
    jnz d1_outer
    pop r1
    pop r0
    rts

; ==============================================================================
; TELAS FINAIS
; ==============================================================================
win_game_screen:
    call ClearScreen
    loadn r0, #530
    loadn r1, #str_win
    loadn r2, #512
    call PrintStringColor
    jmp ask_retry

game_over_lose:
    call ClearScreen
    loadn r0, #530
    loadn r1, #str_lose
    loadn r2, #2304
    call PrintStringColor
    jmp ask_retry

thanks_screen: 
    call ClearScreen
    loadn r0, #530       
    loadn r1, #str_thanks 
    loadn r2, #3840      
    call PrintStringColor
    call Delay1Sec        
    jmp halt_sys

ask_retry:
    loadn r0, #650
    loadn r1, #str_retry
    loadn r2, #3840
    call PrintStringColor
ar_loop:
    inchar r0
    load r1, KEY_Y
    cmp r0, r1
    jeq start_program
    load r1, KEY_N
    cmp r0, r1
    jeq thanks_screen
    jmp ar_loop

halt_sys:
    jmp halt_sys 
