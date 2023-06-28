% experiment instructions (during practice session)

fontsize_instr_big = 25;
fontsize_instr_small = 21;

% screen 1: welcome to the experiment
cgfont('Arial',fontsize_instr_big);
exp_instr_1_0     = 'Ciao!';
exp_instr_1_1     = 'Ti chiedo leggere attentamente le seguenti istruzioni e ';
exp_instr_1_2     = 'se hai delle domande puoi chiedere alle sperimentatrici. ';

cgtext(exp_instr_1_0,mWidth,100);
cgtext(exp_instr_1_0,-mWidth,100);
cgtext(exp_instr_1_1,mWidth,-100);
cgtext(exp_instr_1_1,-mWidth,-100);
cgtext(exp_instr_1_2,mWidth,-150);
cgtext(exp_instr_1_2,-mWidth,-150);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 2: perceptual task
exp_instr_2_0     = 'COMPITO';%'Your task';
exp_instr_2_1     = 'Questo é un compito di percezione.';
exp_instr_2_2     = 'Vedrai 2 stimoli sullo schermo, uno dopo l''altro.';
exp_instr_2_3     = 'Ogni stimolo apparirà velocemente,';
exp_instr_2_4     = 'per cui dovrai fare molta attenzione.';

exp_instr_2_5     = 'Ogni stimolo è costituito da 6 piccole griglie disposte in cerchio.';
exp_instr_2_6     = 'Una delle griglie è diversa dalle altre: ha un contrasto maggiore.';
exp_instr_2_7     = 'Questa griglia può apparire o nel primo o nel secondo stimolo.';
exp_instr_2_8     = 'Il tuo compito è di decidere quando è apparsa questa griglia';
exp_instr_2_8a    = '(1° stimolo        ?        2° stimolo).';
exp_instr_2_9     = 'Nella prossima schermata vedrai un esempio di uno di questi stimoli.';
exp_instr_2_10    = 'Importante: fissa sempre la croce al centro dello stimolo.';


cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_2_0,mWidth,400);
cgtext(exp_instr_2_0,-mWidth,400);
cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_2_1,mWidth,300);
cgtext(exp_instr_2_1,-mWidth,300);
cgtext(exp_instr_2_2,mWidth,250);
cgtext(exp_instr_2_2,-mWidth,250);
cgtext(exp_instr_2_3,mWidth,200);
cgtext(exp_instr_2_3,-mWidth,200);
cgtext(exp_instr_2_4,mWidth,150);
cgtext(exp_instr_2_4,-mWidth,150);
cgtext(exp_instr_2_5,mWidth,-50);
cgtext(exp_instr_2_5,-mWidth,-50);
cgtext(exp_instr_2_6,mWidth,-100);
cgtext(exp_instr_2_6,-mWidth,-100);
cgtext(exp_instr_2_7,mWidth,-150);
cgtext(exp_instr_2_7,-mWidth,-150);
cgtext(exp_instr_2_8,mWidth,-200);
cgtext(exp_instr_2_8,-mWidth,-200);
cgtext(exp_instr_2_8a,mWidth,-300);
cgtext(exp_instr_2_8a,-mWidth,-300);
cgtext(exp_instr_2_9,mWidth,-400);
cgtext(exp_instr_2_9,-mWidth,-400);
cgtext(exp_instr_2_10,mWidth,-450);
cgtext(exp_instr_2_10,-mWidth,-450);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 3: stimulus example
loadpict('C:\Users\OTB\Documents\GitHub\joint-motor-decision\scripts\stimulus_2.png',1,0,0);
drawpict(1);
waitkeydown(inf,71);
drawpict(2);
cgflip(background(1),background(2),background(3));
% wait(100);

% screen 4: response
exp_instr_3_0     = 'Se la griglia diversa appare nel 1° stimolo,';
exp_instr_3_01    = 'premi il pulsante a sinistra.';
exp_instr_3_1     = 'Se la griglia diversa appare nel 2° stimolo,';
exp_instr_3_11    = 'premi il pulsante a destra.';
exp_instr_3_2     = 'Usa sempre l''indice destro per premere i pulsanti.';
exp_instr_3_3     = 'Importante:';
exp_instr_3_4     = 'tieni l''indice sul pulsante di start (quello più vicino a te)';
exp_instr_3_5     = ' fino a quando non appare il ? .';

cgtext(exp_instr_3_0,mWidth,300);
cgtext(exp_instr_3_0,-mWidth,300);
cgtext(exp_instr_3_01,mWidth,250);
cgtext(exp_instr_3_01,-mWidth,250);
cgtext(exp_instr_3_1,mWidth,150);
cgtext(exp_instr_3_1,-mWidth,150);
cgtext(exp_instr_3_11,mWidth,100);
cgtext(exp_instr_3_11,-mWidth,100);
cgtext(exp_instr_3_2,mWidth,-100);
cgtext(exp_instr_3_2,-mWidth,-100);
cgtext(exp_instr_3_3,mWidth,-250);
cgtext(exp_instr_3_3,-mWidth,-250);
cgtext(exp_instr_3_4,mWidth,-300);
cgtext(exp_instr_3_4,-mWidth,-300);
cgtext(exp_instr_3_5,mWidth,-350);
cgtext(exp_instr_3_5,-mWidth,-350);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 5: confidence scale example
exp_instr_5_0     = 'Dopo aver preso la decisione, indica quanto sei sicuro/a';
exp_instr_5_1     = 'su una scala da 1 a 6 (esempio nella prossima schermata).';
exp_instr_5_2     = '6 = moltissimo';
exp_instr_5_3     = '1 = pochissimo';

exp_instr_5_4     = 'IMPORTANTE: usa tutti i livelli della scala!';

cgtext(exp_instr_5_0,mWidth,300);
cgtext(exp_instr_5_0,-mWidth,300);
cgtext(exp_instr_5_1,mWidth,250);
cgtext(exp_instr_5_1,-mWidth,250);
cgtext(exp_instr_5_2,mWidth,150);
cgtext(exp_instr_5_2,-mWidth,150);
cgtext(exp_instr_5_3,mWidth,100);
cgtext(exp_instr_5_3,-mWidth,100);
cgtext(exp_instr_5_4,mWidth,-200);
cgtext(exp_instr_5_4,-mWidth,-200);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 5.2: confidence scale example
loadpict('C:\Users\OTB\Documents\GitHub\joint-motor-decision\scripts\confidence_2.png',1,0,0);
drawpict(1);
waitkeydown(inf,71); % stay on screen until space bar is pressed
drawpict(2);
cgflip(background(1),background(2),background(3));
% wait(100);


% screen 6: goal
exp_instr_6_0     = 'OBIETTIVO';
exp_instr_6_1     = 'Siete un team: entrambi siete nella stessa squadra.';
exp_instr_6_2     = 'L''obiettivo della squadra è di raggiungere il più alto punteggio possibile.';
exp_instr_6_3     = 'In ogni trial, un colore (blu o giallo) apparirà per dirvi chi comincia.';
exp_instr_6_31b   = 'Tu sei il BLU!';
exp_instr_6_31y   = 'Tu sei il GIALLO!';
exp_instr_6_32    = 'Se il blu comincia, vede gli stimoli e prende la sua decisione da solo/a.';
exp_instr_6_4     = 'Poi, il giallo vede gli stimoli e prende la sua decisione da solo/a.';
exp_instr_6_4a    = 'Il blu può guardare il giallo prendere la sua decisione.';
exp_instr_6_5     = 'Dopodiché, il blu prende la decisione di squadra (senza riguardare gli stimoli).';
exp_instr_6_6     = 'Nel trial successivo, l''ordine si inverte.';
exp_instr_6_7     = 'Importante: in ogni trial, blu e giallo vedono gli stessi stimoli.';
                  
cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_6_0,mWidth,400);
cgtext(exp_instr_6_0,-mWidth,400);
cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_6_1,mWidth,300);
cgtext(exp_instr_6_1,-mWidth,300);
cgtext(exp_instr_6_2,mWidth,250);
cgtext(exp_instr_6_2,-mWidth,250);
cgtext(exp_instr_6_3,mWidth,0);
cgtext(exp_instr_6_3,-mWidth,0);
cgtext(exp_instr_6_31y,mWidth,-50);
cgtext(exp_instr_6_31b,-mWidth,-50);
cgtext(exp_instr_6_32,mWidth,-100);
cgtext(exp_instr_6_32,-mWidth,-100);
cgtext(exp_instr_6_4,mWidth,-150);
cgtext(exp_instr_6_4,-mWidth,-150);
cgtext(exp_instr_6_4a,mWidth,-200);
cgtext(exp_instr_6_4a,-mWidth,-200);
cgtext(exp_instr_6_5,mWidth,-250);
cgtext(exp_instr_6_5,-mWidth,-250);
cgtext(exp_instr_6_6,mWidth,-300);
cgtext(exp_instr_6_6,-mWidth,-300);
cgtext(exp_instr_6_7,mWidth,-400);
cgtext(exp_instr_6_7,-mWidth,-400);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed

% screen 6a: JOINT goal
exp_instr_6a_0     = '!LA DECISIONE DI SQUADRA!';
exp_instr_6a_1     = 'In ogni trial, la decisione più importante è l''ultima,';
exp_instr_6a_1a    = 'ossia quella di squadra.';

exp_instr_6a_1b    = 'Prima della decisione di squadra, sarete informati sulle decisioni individuali.';
exp_instr_6a_1c    = 'Saprete la decisione del blu e del giallo (e se queste sono uguali o no),';
exp_instr_6a_1d    = 'ma non vi diremo la risposta corretta.';
exp_instr_6a_1e    = 'A partire da questa informazione, prenderete la decisione di squadra.';

exp_instr_6a_2     = 'Cercate di essere più accurati possibile nel prendere questa decisione.';
exp_instr_6a_3     = 'E'' più importante essere accurati in questa decisione';
exp_instr_6a_3a    = 'che in quelle individuali.';
exp_instr_6a_4     = 'Solo il punteggio di squadra sarà calcolato.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_6a_0,mWidth,400);
cgtext(exp_instr_6a_0,-mWidth,400);

cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_6a_1,mWidth,200);
cgtext(exp_instr_6a_1,-mWidth,200);
cgtext(exp_instr_6a_1a,mWidth,150);
cgtext(exp_instr_6a_1a,-mWidth,150);

cgtext(exp_instr_6a_1b,mWidth,50);
cgtext(exp_instr_6a_1b,-mWidth,50);
cgtext(exp_instr_6a_1c,mWidth,0);
cgtext(exp_instr_6a_1c,-mWidth,0);
cgtext(exp_instr_6a_1d,mWidth,-50);
cgtext(exp_instr_6a_1d,-mWidth,-50);
cgtext(exp_instr_6a_1e,mWidth,-100);
cgtext(exp_instr_6a_1e,-mWidth,-100);

cgtext(exp_instr_6a_2,mWidth,-200);
cgtext(exp_instr_6a_2,-mWidth,-200);
cgtext(exp_instr_6a_3,mWidth,-250);
cgtext(exp_instr_6a_3,-mWidth,-250);
cgtext(exp_instr_6a_3a,mWidth,-300);
cgtext(exp_instr_6a_3a,-mWidth,-300);
cgtext(exp_instr_6a_4,mWidth,-400);
cgtext(exp_instr_6a_4,-mWidth,-400);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed

% screen 7: information exchange
cgfont('Arial',fontsize_instr_big);
exp_instr_7_0     = 'Durante l''esperimento non potete parlare.';
exp_instr_7_1     = 'Tuttavia, capirete le decisioni del vostro compagno di squadra';
exp_instr_7_2     = '(partner) osservando i suoi movimenti.';

cgtext(exp_instr_7_0,mWidth,100);
cgtext(exp_instr_7_0,-mWidth,100);
cgtext(exp_instr_7_1,mWidth,-100);
cgtext(exp_instr_7_1,-mWidth,-100);
cgtext(exp_instr_7_2,mWidth,-150);
cgtext(exp_instr_7_2,-mWidth,-150);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed


% screen 8: experiment structure
exp_instr_8_0     = 'STRUTTURA DELL''ESPERIMENTO';
exp_instr_8_1     = 'L''esperimento è diviso in 4 parti uguali.';
exp_instr_8_2     = 'Dopo ogni parte ci saranno delle pause, nelle quali saprete';
exp_instr_8_3     = 'il punteggio di squadra raggiunto.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_8_0,mWidth,200);
cgtext(exp_instr_8_0,-mWidth,200);
% cgfont('Arial',fontsize_instr_small);
cgtext(exp_instr_8_1,mWidth,0);
cgtext(exp_instr_8_1,-mWidth,0);
cgtext(exp_instr_8_2,mWidth,-200);
cgtext(exp_instr_8_2,-mWidth,-200);
cgtext(exp_instr_8_3,mWidth,-250);
cgtext(exp_instr_8_3,-mWidth,-250);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed

% screen 9: ready for experiment?
exp_instr_9_0     = 'Prima che l''esperimento cominci, farete pratica.';
exp_instr_9_1     = 'Se siete pronti cominciamo con la pratica.';
exp_instr_9_2     = 'RICORDATE che l''obiettivo è ottenere ';
exp_instr_9_3     = 'il punteggio di squadra più alto possibile.';

cgfont('Arial',fontsize_instr_big);
cgtext(exp_instr_9_0,mWidth,200);
cgtext(exp_instr_9_0,-mWidth,200);
cgtext(exp_instr_9_1,mWidth,0);
cgtext(exp_instr_9_1,-mWidth,0);
cgtext(exp_instr_9_2,mWidth,-200);
cgtext(exp_instr_9_2,-mWidth,-200);
cgtext(exp_instr_9_3,mWidth,-300);
cgtext(exp_instr_9_3,-mWidth,-300);

cgflip(background(1),background(2),background(3));
waitkeydown(inf,71); % stay on screen until space bar is pressed
