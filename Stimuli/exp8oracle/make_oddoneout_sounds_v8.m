function make_oddoneout_sounds_v8(Sid)
%%
% Mixture experiment with 7 conditions
% 1 species, 1 individual
% 1 species, 8 individuals
% 1 species, 32 individuals
% 2 species, 8 individuals + 1 individual (different)
% 2 species, 8 individuals + 1 individual (similar)
% 2 species, 8 individuals + 8 individuals (different)
% 2 species, 8 individuals + 8 individuals (similar)
%
%%
clearvars -except Sid

rng('shuffle')

% Sid = '01';

mkdir(['_discrimination_task_8a_S' Sid ''])
rmdir(['_discrimination_task_8a_S' Sid ''], 's')
mkdir(['_discrimination_task_8a_S' Sid ''])

ds = [dir('../_sorted3/C*');...
      dir('../_sorted3/D*');...
      dir('../_sorted3/E*');...
      dir('../_sorted3/S*');...
      dir('../_sorted3/W*')];

fs = 20e3;

rx = [1 10  8;
      2  4 10;
      3  6  7;
      4  9  5;
      5  8  4;
      6  7  9;
      7  2  3;
      8  5  1;
      9  3  6;
      10 1  2];

NI1x = [1 8 8 8 32];
NI2x = [0 0 1 8 0];
  
for k = 1:length(ds)
    clear ID
    d = dir([ds(k).folder '/' ds(k).name '/*.wav']);
    
    for n = 1:length(d)
        I = findstr(d(n).name,'_');
        ID(n) = str2num(d(n).name(1:I-1));
    end
    uID = unique(ID);
    for Tr = 1:5
        for mm = 1:2
            for IDur = [2]
               w = 0.5*make_window(IDur,0.02,20e3);
               for NI = 1:length(NI1x)
%                    for NI2 = [0 8]
                    NI1 = NI1x(NI);
                    NI2 = NI2x(NI);
                       clear ID1
                       if mm == 1
                           rd = rx(k,2);
                       elseif mm == 2
                           rd = rx(k,3);
                       end
                        
                        d1 = dir([ds(rd(1)).folder '/' ds(rd).name '/*.wav']);
                        for n = 1:length(d1)
                            I = findstr(d1(n).name,'_');
                            ID1(n) = str2num(d1(n).name(1:I-1));
                        end
                        uID1 = unique(ID1);
                       
                        clear x x1 x2
                        rID = [uID(randperm(length(uID)));uID(randperm(length(uID)))]';
%                         rID = [rID(1:length(uID)/2,1);rID(:,2);rID(length(uID)/2+1:end,1)];
                        rID1 = [uID1(randperm(length(uID1)));uID1(randperm(length(uID1)))]';
%                         rID1 = [rID1(1:length(uID1)/2,1);rID1(:,2);rID1(length(uID1)/2+1:end,1)];
                        
                        for m = 1:NI1
                            
                            dstim1 = dir([d(k).folder '/' num2str(rID(m),'%02.f') '*.wav']);

                            r1 = randperm(length(dstim1));

                            [x1(:,1,m) fs] = audioread([dstim1(r1(1)).folder '/' dstim1(r1(1)).name]);
                            [x1(:,2,m) fs] = audioread([dstim1(r1(1)).folder '/' dstim1(r1(1)).name]);
                            [x1(:,3,m) fs] = audioread([dstim1(r1(2)).folder '/' dstim1(r1(2)).name]);
                            x1(:,1,m) = x1(:,1,m) * 0.01/rms(squeeze(x1(:,1,m)));
                            x1(:,2,m) = x1(:,2,m) * 0.01/rms(squeeze(x1(:,2,m)));
                            x1(:,3,m) = x1(:,3,m) * 0.01/rms(squeeze(x1(:,3,m)));
                        
                        end
                        x1 = sum(x1,3);

                        if NI2 > 0
                            x2 = zeros(size(x1));
                            for m = 1:NI2
                                dstim2 = dir([d1(1).folder '/' num2str(rID1(m),'%02.f') '*.wav']);

                                r2 = randperm(length(dstim2));

                                [x2(:,1,m) fs] = audioread([dstim2(r2(1)).folder '/' dstim2(r2(1)).name]);
                                [x2(:,2,m) fs] = audioread([dstim2(r2(1)).folder '/' dstim2(r2(1)).name]);
                                [x2(:,3,m) fs] = audioread([dstim2(r2(2)).folder '/' dstim2(r2(2)).name]);
                                x2(:,1,m) = x2(:,1,m) * 0.01/rms(squeeze(x2(:,1,m)));
                                x2(:,2,m) = x2(:,2,m) * 0.01/rms(squeeze(x2(:,2,m)));
                                x2(:,3,m) = x2(:,3,m) * 0.01/rms(squeeze(x2(:,3,m)));
                            end
                            x2 = sum(x2,3);
                            % x = x1+x2;
                        else
                            % x = x1;
                        end

                        if (NI2 == 1 || NI2 == 8)
                            x = x2;
                        else
                            x = x1;
                        end

                        [b,a] = butter(5,80/(fs/2),'high');
                        for m = 1:3
                            x(:,m) = x(:,m) * 0.01/rms(x(:,m));
                            p(:,m) = pinknoise(size(x,1));
                            p(:,m) = 0*filtfilt(b,a,p(:,m));
                        end
                        
%                         rmsT = 1;
%                         while(rmsT)
%                             IDurL1 = floor(randi(fs*(2-IDur)+1));
%                             IDurID1 = IDurL1:IDurL1+IDur*fs-1;
%                             IDurL2 = floor(randi(fs*(2-IDur)+1));
%                             IDurID2 = IDurL2:IDurL2+IDur*fs-1;
%                             if rms(x(IDurID1,1)) > rms(x(:,1))/4 && ...
%                                rms(x(IDurID1,2)) > rms(x(:,2))/4 && ...
%                                rms(x(IDurID2,3)) > rms(x(:,3))/4
%                                rmsT = 0;
%                             end
%                         end
                        
                        x = [x(:,1) x(:,2) x(:,3)];
                        
                        TP = randperm(3);
                        x(:,TP) = x+p;
                        
                        y = [w.*x(:,1);zeros(fs*0.5,1);w.*x(:,2);zeros(fs*0.5,1);w.*x(:,3)];
                        if ~(NI1 == 32 && NI2 == 8)
                            if ~(mm == 2 && NI2 == 0)
%                                 if ~(mm == 2 && NI1 == 1)
                                    if k < 10
                                        audiowrite(['_discrimination_task_8a_S' Sid '/Stim0' num2str(k) '_Dur' num2str(IDur,'%1.2f') '_SI' num2str(NI1,'%02.f') '_TI' num2str(NI2,'%02.f') '_T' num2str(mm) '_Tr' num2str(Tr,'%02.f') '_TP' num2str(TP(3)) '.wav'],y,fs)
                                    else
                                        audiowrite(['_discrimination_task_8a_S' Sid '/Stim' num2str(k) '_Dur' num2str(IDur,'%1.2f') '_SI' num2str(NI1,'%02.f') '_TI' num2str(NI2,'%02.f') '_T' num2str(mm) '_Tr' num2str(Tr,'%02.f') '_TP' num2str(TP(3)) '.wav'],y,fs)
                                    end
%                                 end
                            end
                        end
%                    end
                end
            end
        end
    end
end

