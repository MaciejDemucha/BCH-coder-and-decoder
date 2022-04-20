clear;

%przykladowe dane
n = 15;
k = 5;
m = 4;
t = 3;
gen_pol_str = dec2bin(2467);
kodowe = 0b101010010100010;

%Algorytm kodowania

%przesuniecie kodowego o n-k w lewo
kodowe_przesuniete = dec2bin(bitsll(kodowe, n-k));
%porownanie po przesunieciu
fprintf("Przed: %s\n", dec2bin(kodowe));
fprintf("Po: %s\n", kodowe_przesuniete);
%zamiana stringu przesunietego kodowego na wielomian
kodowe_to_array = str2num(sprintf('%c ',kodowe_przesuniete(:)));
[kodowe_poly] = poly2sym(kodowe_to_array);
%analogicznie generacyjny
gen_to_array = str2num(sprintf('%c ',gen_pol_str(:)));
[gen_poly] = poly2sym(gen_to_array);
%podzielenie kodowego przez generacyjny
[r,q] = polynomialReduce(kodowe_poly,gen_poly);
%obliczenie c(x) - wektora kodowego
cx = kodowe_poly + r;

%Algorytm dekodowania

%wektor bledow
e = dec2bin(0b001001000010010); 
e_to_array = str2num(sprintf('%c ',e(:)));
[e_poly] = poly2sym(e_to_array);
%wektor kodowy otrzymany: suma wektora wysylanego i wektora bledow
cy = cx + e_poly;
%wyznaczamy syndrom (informację o pozycji błędów odebranego wektora kodowego)
[s,q_s] = polynomialReduce(cy,gen_poly);
waga_hamminga = nnz(s);
%korekta bledow
if waga_hamminga <= t
    cd= cy + s;
else
    i = 0;
    while waga_hamminga > t
        syms x
        cy_new = bitsra(sym2poly(cy), 1);
        cy = poly2sym(cy_new);
        [s,q_s] = polynomialReduce(cy,gen_poly);
        waga_hamminga = nnz(s);
        i = i + 1;
        if i == k
            break
        end
    end
if i == k
        fprintf('Błędy niekorygowalne');
else
    cd= cy + s;
    cd_przesuniete = bitsll(sym2poly(cd), i);
    cd = poly2sym(cd_przesuniete);
end
end

%proba znalezienia wielomianu generujacego
%syms x;
%a=x^4+x^3+x^2+x+1;
%b=x^4+x+1;
%c=x^2+x+1;
%[out1] = lcm(a,b);
%[out_final] = lcm(out1,c);

%m = 4;
%[y] = primpoly(m, 'all');
