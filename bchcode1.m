clear;

%przykladowe dane
n = 15;         %dlugosc wektora kodowego
k = 5;          %dlugosc ciagu informacyjnego      
t = 3;          %zdolnosc korekcyjna
gen_str = dec2bin(1335);    %2467 octal
ciag_info = 0b10100; %ciag informacyjny

%gen_str = dec2bin(3929);       %7531 octal
%k = 4;

%Algorytm kodowania

%rozszerzamy ciag informacyjny, aby nie utracić informacji po przesunieciu
ciag_info_bin = dec2bin(ciag_info, n);
%przesuniecie ciagu kodowego o n-k w lewo
ciag_info_przesuniety = dec2bin(bin2dec(ciag_info_bin) * power(2,n-k));
%porownanie ciagu informacyjnego po przesunieciu
fprintf("Ciag informacyjny przed przesunieciem: %s\n", ciag_info_bin);
fprintf("Ciag informacyjny po przesunieciu: %s\n", ciag_info_przesuniety);
%zamiana stringu przesunietego słowa kodowego na postać wielomianu
ciag_info_array = str2num(sprintf('%c ',ciag_info_przesuniety(:)));
[ciag_info_poly] = poly2sym(ciag_info_array);
%analogicznie postępujemy z wielomianem generacyjnym
gen_array = str2num(sprintf('%c ',gen_str(:)));
[gen_poly] = poly2sym(gen_array);
%podzielenie słowa kodowego przez wielomian generacyjny
%funkcja gfdeconv dokonuje dzielenia w GF(2)
[q,r] = gfdeconv(ciag_info_array,gen_array);
%obliczenie c(x) - wektora kodowego
%dokonujemy dodania słowa kodowego i reszty z powyższego dzielenia 
% na liczbach dziesietnych i zamieniamy z powrotem na wektor cyfr 0 i 1
%funkcja bi2de traktuje ostatni bit od prawej jako najmniej znaczący, 
% dlatego potrzebujemy odwrócić wektor za pomocą funkcji 
% fliplr przed i po dodaniem
cx_array = fliplr(de2bi(bi2de(fliplr(ciag_info_array))+bi2de(fliplr(r))));
%zamiana wektora kodowego z tablicy cyfr na postać wielomianową
cx = poly2sym(cx_array);

%Algorytm dekodowania

%wektor bledow w postaci stringu
e = dec2bin(0b00100); 
%tablicy cyfr
e_array = str2num(sprintf('%c ',e(:)));
%wielomianu
[e_poly] = poly2sym(e_array);
%wektor kodowy otrzymany: suma wektora wysylanego i wektora bledow
cy_array = fliplr(de2bi(bi2de(fliplr(cx_array))+bi2de(fliplr(e_array))));
cy = poly2sym(cy_array);
%wyznaczamy syndrom (informację o pozycji błędów odebranego wektora kodowego)
%poprzez podzielenie wektora błędów przez wielomian generacyjny
[q_s,s] = gfdeconv(e_array,gen_array);
[s_poly] = poly2sym(s);
%liczymy wagę Hamminga - liczbę niezerowych cyfr w syndromie
waga_hamminga = nnz(s);
%korekta bledow, jeśli waga Hamminga nie jest większa od max zdolności
%korekcyjnej to możemy dodać syndrom do otrzymanego wektora kodowego
if waga_hamminga <= t
    cd = fliplr(de2bi(bi2de(fliplr(cy_array))+bi2de(fliplr(s))));
    cd_poly = poly2sym(cd);
%przesuwanie slowa kodowego w prawo, dopoki w(s) > t
else
    i = 0;
    while waga_hamminga > t
        syms x
        cy_new = bitsra(sym2poly(cy), 1);
        cy = poly2sym(cy_new);
        cy_array = sym2poly(cy);
        [q_s,s] = gfdeconv(cy_array,gen_array);
        waga_hamminga = nnz(s);
        i = i + 1;
        if i == k
            break
        end
    end
if i == k
        fprintf('Błędy niekorygowalne');
else
    %korekta bledow i odpowiednie przesuniecie w lewo
    cd = fliplr(de2bi(bi2de(fliplr(cy_array))+bi2de(fliplr(s))));
    cd_przesuniete = bitsll(sym2poly(cd), i);
    cd = poly2sym(cd_przesuniete);
end
end

fprintf("cd: ");
fprintf("%d", cd);
fprintf("\n");
fprintf("cx: ");
fprintf("%d", cx_array);
fprintf("\n");
fprintf("cy: ");
fprintf("%d", cy_array);

%proba znalezienia wielomianu generujacego
%syms x;
%a=x^4+x^3+x^2+x+1;
%b=x^4+x+1;
%c=x^2+x+1;
%[out1] = lcm(a,b);
%[out_final] = lcm(out1,c);

%m = 4;
%[y] = primpoly(m, 'all');
