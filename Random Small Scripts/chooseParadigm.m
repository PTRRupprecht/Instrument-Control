function [line1,line2,line3] = chooseParadigm(samplerate,paradigm)


switch paradigm
    case 0
        %%
        tt = [20 20];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line1 = 1 - line2 - line3;
    case -2
        %%
        tt = [20 20];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
    case -1
        %%
        tt = [20 20];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(:) = 0.33;
        line2(:) = 0.33;
        line1 = 1 - line2 - line3;
        
    case 91
        %%1%% step responses 4x
        tt = [30 60 80];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 92
        %%1%% step responses 4x
        tt = [30 60 80];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 93
        %%1%% step responses 4x
        tt = [30 50 60 80 100];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = linspace(0,0.8,numel(tt(1):tt(2)));
        line2(tt(2):tt(3)) = 0.8;
        line2(tt(3):tt(4)) = linspace(0.8,0,numel(tt(3):tt(4)));
        line1 = 1 - line2 - line3;
    case 94
        %%1%% step responses 4x
        tt = [30 50 60 80 100];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = linspace(0,0.8,numel(tt(1):tt(2)));
        line3(tt(2):tt(3)) = 0.8;
        line3(tt(3):tt(4)) = linspace(0.8,0,numel(tt(3):tt(4)));
        line1 = 1 - line2 - line3;
    case 95
        tt = [30 50 80 100 120];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line2(tt(2):tt(3)) = linspace(0.8,0,numel(tt(2):tt(3)));
        line3(tt(2):tt(3)) = linspace(0,0.8,numel(tt(2):tt(3)));
        line3(tt(3):tt(4)) = 0.8;
        line1 = 1 - line2 - line3;
       case 96
        tt = [30 50 80 100 120];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = 0.8;
        line3(tt(2):tt(3)) = linspace(0.8,0,numel(tt(2):tt(3)));
        line2(tt(2):tt(3)) = linspace(0,0.8,numel(tt(2):tt(3)));
        line2(tt(3):tt(4)) = 0.8;
        line1 = 1 - line2 - line3;
        
        
    case 81
        %%1%% step responses 4x
        tt = [10 20 40 50 60];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line3(tt(3):tt(4)) = 0.8;
        line1 = 1 - line2 - line3;
        
        
    case 11
        %%1%% step responses 4x
        tt = [10 35 50]+00;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 111
        %%1%% step responses 4x
        tt = [10 20 35]+0;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 12
        %%1%% step responses 4x
        tt = [10 15 30]+0;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 122
        %%1%% step responses 4x
        tt = [10 20 35]+0;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = 0.8;
        line1 = 1 - line2 - line3;
    case 1
        %%1%% step responses 4x
        tt = [10 45 80 115 150 185 220 255 305]+20;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
%         line2(tt(5):tt(6)) = 0.8;
        line3(tt(3):tt(4)) = 0.8;
%         line3(tt(7):tt(8)) = 0.8;
        line1 = 1 - line2 - line3;
    case 99
        %%1%% step responses 4x
        tt = [10 15 20 25 30 35 40 45 50 55 60]+0;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line2(tt(5):tt(6)) = 0.8;
        line3(tt(3):tt(4)) = 0.8;
        line3(tt(7):tt(8)) = 0.8;
        line1 = 1 - line2 - line3;
    case 42
        %%42%% only one odorant
        tt = [10 50 80 80 80 80 130 140]+10;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
%         line2(tt(5):tt(6)) = 0.8;
        line2(tt(3):tt(4)) = linspace(0,0.8,numel(tt(3):tt(4)));
        line2(tt(4):tt(5)) = linspace(0.8,0,numel(tt(4):tt(5)));
%         line3(tt(7):tt(8)) = 0.8;
        line1 = 1 - line2;
    case 32
        %%42%% only one odorant
        tt = [10 45 90 130 170 215 260 290]+20;
        tt = [10 50 80 80 80 80 130 140]+10;
        
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line3(tt(1):tt(2)) = 0.8;
%         line2(tt(5):tt(6)) = 0.8;
        line3(tt(3):tt(4)) = linspace(0,0.8,numel(tt(3):tt(4)));
        line3(tt(4):tt(5)) = linspace(0.8,0,numel(tt(4):tt(5)));
%         line3(tt(7):tt(8)) = 0.8;
        line1 = 1 - line3;
    case 33
        %%42%% only one odorant
        tt = [1 3 90 ]+0;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.4;
%         line2(tt(5):tt(6)) = 0.8;
%         line2(tt(3):tt(4)) = linspace(0,0.4,numel(tt(3):tt(4)));
%         line2(tt(4):tt(5)) = linspace(0.4,0,numel(tt(4):tt(5)));
%         line3(tt(7):tt(8)) = 0.8;
        line1 = 1 - line2*2;
    case 2
        %%2%% pre-response (masking)
        tt = [10 13 50 90 93 130 160];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = 0.8;
        line2(tt(4):tt(5)) = 0.8;
        line3(tt(2)+1:tt(3)) = 0.8;
        line3(tt(5)+1:tt(6)) = 0.8;
        line1 = 1 - line2 - line3;
    case 3
        %%3%% deception paradigm
        tt = [10 50 70 90 130 170   210 230   250 290 330 ]+20;
%         tt = [10 10 10 10 50 90   130 130   130 130 170 ]+20;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = linspace(0,0.8,numel(tt(1):tt(2)));
        line2(tt(2):tt(3)) = linspace(0.8,0.4,numel(tt(2):tt(3)));
        line3(tt(2):tt(3)) = linspace(0,0.4,numel(tt(2):tt(3)));
        line2(tt(3):tt(4)) = linspace(0.4,0.8,numel(tt(3):tt(4)));
        line3(tt(3):tt(4)) = linspace(0.4,0,numel(tt(3):tt(4)));
        line2(tt(4):tt(5)) = 0.8;
        line2(tt(5):tt(6)) = linspace(0.8,0,numel(tt(5):tt(6)));
        line3(tt(5):tt(6)) = linspace(0,0.8,numel(tt(5):tt(6)));
        line3(tt(6):tt(7)) = 0.8;
        line3(tt(7):tt(8)) = linspace(0.8,0.4,numel(tt(7):tt(8)));
        line2(tt(7):tt(8)) = linspace(0,0.4,numel(tt(7):tt(8)));
        line3(tt(8):tt(9)) = linspace(0.4,0.8,numel(tt(8):tt(9)));
        line2(tt(8):tt(9)) = linspace(0.4,0.0,numel(tt(8):tt(9)));
        line3(tt(9):tt(10)) = linspace(0.8,0,numel(tt(9):tt(10)));
%         line3(tt(10):tt(11)) = linspace(0.8,0,numel(tt(10):tt(11)));

%         line2 = [line2;line2];
%         line3 = [line3;line3];
        line1 = 1 - line2 - line3;
    case 302
        %%3%% deception paradigm
        tt = [10 50 70 90 130 170   210 230   250 290 330 ]+20;
        tt = [10 10 10 10 50 90   130 130   130 130 170 ]+20;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = linspace(0,0.8,numel(tt(1):tt(2)));
        line2(tt(2):tt(3)) = linspace(0.8,0.4,numel(tt(2):tt(3)));
        line3(tt(2):tt(3)) = linspace(0,0.4,numel(tt(2):tt(3)));
        line2(tt(3):tt(4)) = linspace(0.4,0.8,numel(tt(3):tt(4)));
        line3(tt(3):tt(4)) = linspace(0.4,0,numel(tt(3):tt(4)));
        line2(tt(4):tt(5)) = 0.8;
        line2(tt(5):tt(6)) = linspace(0.8,0,numel(tt(5):tt(6)));
        line3(tt(5):tt(6)) = linspace(0,0.8,numel(tt(5):tt(6)));
        line3(tt(6):tt(7)) = 0.8;
        line3(tt(7):tt(8)) = linspace(0.8,0.4,numel(tt(7):tt(8)));
        line2(tt(7):tt(8)) = linspace(0,0.4,numel(tt(7):tt(8)));
        line3(tt(8):tt(9)) = linspace(0.4,0.8,numel(tt(8):tt(9)));
        line2(tt(8):tt(9)) = linspace(0.4,0.0,numel(tt(8):tt(9)));
        line3(tt(9):tt(10)) = linspace(0.8,0,numel(tt(9):tt(10)));
%         line3(tt(10):tt(11)) = linspace(0.8,0,numel(tt(10):tt(11)));

%         line2 = [line2;line2];
%         line3 = [line3;line3];
        line1 = 1 - line2 - line3;
    case 301
        %%3%% deception paradigm
        tt = [10 50 70 90 130 170   210 230   250 290 330 ]+20;
        tt = [10 10 10 10 50 90   130 130   130 130 170 ]+20;
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(2)) = linspace(0,0.8,numel(tt(1):tt(2)));
        line2(tt(2):tt(3)) = linspace(0.8,0.4,numel(tt(2):tt(3)));
        line3(tt(2):tt(3)) = linspace(0,0.4,numel(tt(2):tt(3)));
        line2(tt(3):tt(4)) = linspace(0.4,0.8,numel(tt(3):tt(4)));
        line3(tt(3):tt(4)) = linspace(0.4,0,numel(tt(3):tt(4)));
        line2(tt(4):tt(5)) = 0.8;
        line2(tt(5):tt(6)) = linspace(0.8,0,numel(tt(5):tt(6)));
        line3(tt(5):tt(6)) = linspace(0,0.8,numel(tt(5):tt(6)));
        line3(tt(6):tt(7)) = 0.8;
        line3(tt(7):tt(8)) = linspace(0.8,0.4,numel(tt(7):tt(8)));
        line2(tt(7):tt(8)) = linspace(0,0.4,numel(tt(7):tt(8)));
        line3(tt(8):tt(9)) = linspace(0.4,0.8,numel(tt(8):tt(9)));
        line2(tt(8):tt(9)) = linspace(0.4,0.0,numel(tt(8):tt(9)));
        line3(tt(9):tt(10)) = linspace(0.8,0,numel(tt(9):tt(10)));
        temp = line3;
        line3 = line2; line2 = temp;
%         line3(tt(10):tt(11)) = linspace(0.8,0,numel(tt(10):tt(11)));

%         line2 = [line2;line2];
%         line3 = [line3;line3];
        line1 = 1 - line2 - line3;
    case 4
        %%4%% hidden odor paradigm
        tt = [10 50 90 130 150 190 220];
        tt = tt*samplerate;
        line1 = zeros(tt(end),1); line2 = zeros(tt(end),1); line3 = zeros(tt(end),1);
        line2(tt(1):tt(3)) = 0.05;
        line3(tt(2):tt(3)) = 0.75;
        line3(tt(3):tt(4)) = linspace(0.75,0,numel(tt(3):tt(4)));
        line2(tt(3):tt(4)) = linspace(0.05,0.75,numel(tt(3):tt(4)));
        line2(tt(4):tt(5)) = 0.75;
        line2(tt(5):tt(6)) = linspace(0.75,0,numel(tt(5):tt(6)));
%         line2 = [line2;line2];
%         line3 = [line3;line3];
        line1 = 1 - line2 - line3;
end
try
    close 4
end
figure(4), hold on,
plot((1:numel(line1))/samplerate,line1);
plot((1:numel(line1))/samplerate,line2,'r');
plot((1:numel(line1))/samplerate,line3,'k');
hold off,
end
