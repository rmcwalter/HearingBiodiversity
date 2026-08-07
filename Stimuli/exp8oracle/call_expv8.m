function call_expv8

%%

clear all

for k = 11:50
    if k < 10
        make_oddoneout_sounds_v8(['0' num2str(k)])
    else
        make_oddoneout_sounds_v8(num2str(k))
    end
end