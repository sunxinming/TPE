%file: HC_RDH.m
%function: the first data hiding method to embedding the data for recovery
%origin: the original image
%data: the data to be embeded
%locatex & locatey: the location of first pixel in embedding block
 

function res = HC_RDH( origin, data, locatex, locatey)
    res = origin;
    tmp = '000000000000000000000';
    [~,number] = size(locatex);
    [~,~,C] = size(origin);
    [~,limit] = size(data);
    data(limit+1) = '1'; % adding the ending flag
    limit = limit + 1;
    count = 1; %record the index of the data to be embedded
    for chanal = 1 : 1 : C
        for index = 1 : 1 : number
            % the first pixel value of each block for prediction
            pred = origin(locatex(index),locatey(index),chanal);
            d1 = Diff(pred,origin(locatex(index),locatey(index)+1,chanal));
            d2 = Diff(pred,origin(locatex(index)+1,locatey(index),chanal));
            d3 = Diff(pred,origin(locatex(index)+1,locatey(index)+1,chanal));
            d = uint8(d1);
            if d2 > d
                d = d2;
            end
            if d3 > d
                d = d3;
            end
            md = 8 - d; % the max number of the same bits from MSB that all pixels in one block 
            bits = '000000000000000000000000';
            md = Dec2bin(md,3);
            if md == 0
                continue;
            end
            bits(1:3) = md(1:3);
            c1 = Dec2bin(origin(locatex(index),locatey(index)+1,chanal),8);
            bits(4:3+d) = c1(8-d+1:8);
            c2 = Dec2bin(origin(locatex(index)+1,locatey(index),chanal),8);
            bits(4+d:3+2*d) = c2(8-d+1:8);
            c3 = Dec2bin(origin(locatex(index)+1,locatey(index)+1,chanal),8);
            bits(4+2*d:3+3*d) = c3(8-d+1:8);
            % all the data has been embedded
            if count >= limit
                 bits(4+3*d:24) = tmp(1:21-3*d);
            else
                if count+20-3*d > limit && limit > count
                    data(limit:count+20-3*d) = tmp(1:count+21-3*d-limit);
                    limit = limit + count+21-3*d-limit+1;
                end
                bits(4+3*d:24) = data(count:count+20-3*d);
            end
            count = count + 20-3*d + 1;
            res(locatex(index),locatey(index)+1,chanal) = bin2dec(bits(1:8));
            res(locatex(index)+1,locatey(index),chanal) = bin2dec(bits(9:16));
            res(locatex(index)+1,locatey(index)+1,chanal) = bin2dec(bits(17:24));
        end
    end
end