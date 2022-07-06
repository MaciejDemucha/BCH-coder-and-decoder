clear;

%wejściowe dane
%n = 15;         %dlugosc wektora kodowego
%k = 5;          %dlugosc ciagu informacyjnego  
%t = 3;          %zdolnosc korekcyjna
%gen_str = dec2bin(1335);    %zapisujemy wielomian generacyjny o współczynnikach dziesiętnych i zamieniamy na postać dwójkową (mochnacki - 2467 ósemkowo)
%ciag_info = 0b10100; %ciag informacyjny

n=7;
k=4;
t=1;
gen_str = dec2bin(11);
ciag_info = 0b1101;

%e_array = 0b000000000010101;
e_array = 0b0010000;
e_array = dec2bin(e_array, n);
e_array = str2num(sprintf('%c ',e_array(:)));

%Algorytm kodowania

%rozszerzamy ciag informacyjny, aby nie utracić informacji po przesunieciu
ciag_info_bin = dec2bin(ciag_info, n);
%przesuniecie ciagu kodowego o n-k w lewo, aby 5 bitów od lewej zawierała
%część informacyjną, a pozostałe bity kodową. Przesunięcie jest realizowane
%poprzez mnożenie przez 2^(n-k) więc potrzeba zamienić ciąg informacyjny na
%postać dziesiętną przed mnożeniem
ciag_info_przesuniety = dec2bin(bin2dec(ciag_info_bin) * power(2,n-k));
%porownanie ciagu informacyjnego po przesunieciu
fprintf("Ciag informacyjny przed przesunieciem: %s\n", ciag_info_bin);
fprintf("Ciag informacyjny po przesunieciu: %s\n", ciag_info_przesuniety);
%zamiana przesunietego słowa kodowego z String na wektor liczb
ciag_info_array = str2num(sprintf('%c ',ciag_info_przesuniety(:)));
%analogicznie postępujemy z wielomianem generacyjnym
gen_array = str2num(sprintf('%c ',gen_str(:)));
%podzielenie słowa kodowego przez wielomian generacyjny
%funkcja gfdeconv dokonuje dzielenia w GF(2)
%gfdeconv traktuje pozycje po prawej jako bardziej znaczące, dlatego
%uzywamy fliplr do obracania wektorów podczas użycia tej funckji
[q,r] = gfdeconv(fliplr(ciag_info_array),fliplr(gen_array));
%obliczenie c(x) - wektora kodowego
%dokonujemy dodania słowa kodowego i reszty z powyższego dzielenia 
%uzupełniamy wektor reszty z dzielenia zerami, aby dopasować go rozmiarem
%do ciągu informacyjnego
r = [zeros(1, length(ciag_info_array) - length(r)), r];
%zamieniamy wektory ciągu informacyjnego i reszty na wektory wartości
%logicznych
ciag_info_array = logical(ciag_info_array);
r = logical(r);
%dodawanie w GF(2) jest realizowane jako XOR
cx_array = xor(ciag_info_array, r);
%zamieniamy z powrotem ciag informacyjny i resztę na wektor liczb
ciag_info_array = double(ciag_info_array);
r = double(r);

%Algorytm dekodowania

%losujemy wektor błedów, pierwsze 2 argumenty określają rozmiar wektora, a
%trzeci możliwą ilość błędów
%e_array = randerr(1,n,1:t);

%zamieniamy wektor błędów na wektor wartości logicznych i dokonujemy
%dodania w GF(2), czyli XOR
% wektor kodowy otrzymany: suma wektora wysylanego i wektora bledow
e_array = logical(e_array);
cy_array = xor(cx_array, e_array)
%pomocnicza zmienna do wyświetlenia na końcu rezultatów
cy_print = cy_array;
e_array = double(e_array);
%wyznaczamy syndrom (informację o pozycji błędów odebranego wektora kodowego)
%poprzez podzielenie wektora błędów przez wielomian generacyjny
[q_s,s] = gfdeconv(fliplr(e_array),fliplr(gen_array));
%liczymy wagę Hamminga - liczbę niezerowych bitów w syndromie
waga_hamminga = nnz(s);
%wyświetlenie syndromu
fliplr(s)
%korekta bledow, jeśli waga Hamminga nie jest większa od max zdolności
%korekcyjnej to możemy dodać syndrom do otrzymanego wektora kodowego
if waga_hamminga <= t
    s = [zeros(1, length(cy_array) - length(s)), fliplr(s)];
    s = logical(s);
    cd = xor(cy_array, s);
    s = double(s);
%przesuwanie slowa kodowego w prawo, dopoki w(s) > t
else
    i = 0;
    while waga_hamminga > t
        %zmienna pomocnicza, zachowujemy wektor odebrany
        temp_cy = dec2bin(bin2dec(num2str(double(cy_array))), n);
        %przechowujemy wektor odebrany jako wektor wartości logicznych
        cy_new = logical(str2num(sprintf('%c ',temp_cy(:))));
        %przesuwamy wektor odebrany cyklicznie w prawo o 1
        cy_new = circshift(cy_new, 1)
        cy_array = cy_new;
        cy_array = double(cy_array);
        %dzielimy wektor odebrany przez wielomian generacyjny
        [q_s,s] = gfdeconv(fliplr(cy_array),fliplr(gen_array));
        cy_array = logical(cy_array);
        fliplr(s)
        %ponownie sprawdzamy wagę Hamminga i jeśli nadal jest większa od
        %zdolności korekcyjnej to powtarzamy procedurę
        waga_hamminga = nnz(s)
        i = i + 1;
        %jeśli liczba przesunięć cyklicznych osiągnęła wartość długości
        %częsci informacyjnej to informujemy komunikatem o obecności
        %niekorygowalnych błedów
        if i == k
            fprintf('Błędy niekorygowalne');
        end
    end

    %rozszerzamy syndrom do długości wektora odebranego poprzez wypełnienie
    %zerami
    s = [zeros(1, length(cy_array) - length(s)), fliplr(s)];
    %dodajemy wektor odebrany i syndrom i przesuwamy wynik cyklicznie w lewo tyle samo razy 
    % ile przesuwaliśmy w prawo. Otrzymujemy skorygowany wektor kodowy.
    cd = xor(cy_array, s);
    cd = circshift(cd, -i);
end
fprintf("cd: ");
fprintf("%d", cd);
fprintf("\n");
fprintf("cx: ");
fprintf("%d", cx_array);
fprintf("\n");
fprintf("e : ");
fprintf("%d", e_array);
fprintf("\n");
fprintf("cy: ");
fprintf("%d", cy_print);
fprintf("\n");
fprintf("s : ");
fprintf("%d", s);
fprintf("\n cd == cx?");
isequal(cx_array, cd)

