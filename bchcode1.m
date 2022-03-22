clear;
%m = 4; % Or choose any positive integer value of m.
%alph = gf(2,m) % Primitive element in GF(2^m)

x = input("Wpisz długość słowa wejściowego: "); %pobranie od usera dł słowa wejciowego x
n = input("Wpisz długość słowa kodowego (min. 255): ");
t = input("Wpisz zdolność korekcyjną t: ");
m = fix(log2(n+1)); %liczba wielomianów minimalnych (fix -> cz. całkowita)
k = n - t*m; %cz. informacyjna
xWord = randsrc(x, 1, [0 1]); %losowanie słowa wej
fprintf("Dane wejściowe: "); %wypisanie słowa wej
fprintf("%d", xWord);
y = primpoly(m);
fprintf("m = "); %wypisanie liczby wielomianów minimalnych
fprintf("%d", m);
fprintf(y);

%lcm()  NWW - potrzebne później do wyliczenia wielomianu generującego

%m = 4;
%defaultprimpoly = primpoly(m) % Default primitive poly for GF(16)
%allprimpolys = primpoly(m,'all') % All primitive polys for GF(16)
%i1 = isprimitive(25) % Can 25 be the prim_poly input in gf(...)?
%i2 = isprimitive(21) % Can 21 be the prim_poly input in gf(...)?
