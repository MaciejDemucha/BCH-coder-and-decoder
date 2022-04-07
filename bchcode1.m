clear;

%x = input("Wpisz długość słowa wejściowego: "); %pobranie od usera dł słowa wejciowego x
n = input("Wpisz długość słowa kodowego (min. 255): ");
%t = input("Wpisz zdolność korekcyjną t: ");
%m = fix(log2(n+1)); %liczba wielomianów minimalnych (fix -> cz. całkowita)
%k = n - t*m; %cz. informacyjna
k = input("Wpisz długość części informacyjnej: ");
%xWord = randsrc(x, 1, [0 1]); %losowanie słowa wej
%fprintf("Dane wejściowe: "); %wypisanie słowa wej
%fprintf("%d", xWord);
m = 6;
fprintf("\nm = "); 
fprintf("%d\n", m);
[y] = primpoly(m, 'all'); %wypisanie liczby wielomianów minimalnych ciała galois

gen = lcm(y(1), y(2));      %g(x) = NWW(m1(x), m3(x)....)
for i = 3: length(y)      
    LCM_var = lcm(gen, y(i));
    gen = LCM_var;
end
gen_bin = dec2bin(gen);
fprintf("\nNasze g(x) = "); 
fprintf("%s\n", gen_bin);

[genpoly,t] = bchgenpoly(n,k) %porównanie z gotową funkcją
