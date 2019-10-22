--This function is used to transfor eny given decimal number in full text portuguese Brasil
--Its a copy of the script posted in http://glufke.net/oracle/viewtopic.php?t=36

create or replace function extenso_monetario(valor number) return varchar2 IS
  valor_string varchar2(256);
  valor_conv   VARCHAR2(25);
  ind          NUMBER;
  tres_digitos VARCHAR2(3);
  texto_string varchar2(256);
begin
  valor_conv := to_char(trunc((abs(valor) * 100), 0), '0999999999999999999');
  valor_conv := substr(valor_conv, 1, 18) || '0' ||
                substr(valor_conv, 19, 2);
  if to_number(valor_conv) = 0 then
    return('Zero ');
  end if;
  for ind in 1 .. 7 loop
    tres_digitos := substr(valor_conv, (((ind - 1) * 3) + 1), 3);
    texto_string := '';
    -- Extenso para Centena
    if substr(tres_digitos, 1, 1) = '2' then
      texto_string := texto_string || 'Duzentos ';
    elsif substr(tres_digitos, 1, 1) = '3' then
      texto_string := texto_string || 'Trezentos ';
    elsif substr(tres_digitos, 1, 1) = '4' then
      texto_string := texto_string || 'Quatrocentos ';
    elsif substr(tres_digitos, 1, 1) = '5' then
      texto_string := texto_string || 'Quinhentos ';
    elsif substr(tres_digitos, 1, 1) = '6' then
      texto_string := texto_string || 'Seiscentos ';
    elsif substr(tres_digitos, 1, 1) = '7' then
      texto_string := texto_string || 'Setecentos ';
    elsif substr(tres_digitos, 1, 1) = '8' then
      texto_string := texto_string || 'Oitocentos ';
    elsif substr(tres_digitos, 1, 1) = '9' then
      texto_string := texto_string || 'Novecentos ';
    end if;
    if substr(tres_digitos, 1, 1) = '1' then
      if substr(tres_digitos, 2, 2) = '00' then
        texto_string := texto_string || 'Cem ';
      else
        texto_string := texto_string || 'Cento ';
      end if;
    end if;
    -- Extenso para Dezena
    if substr(tres_digitos, 2, 1) <> '0' and texto_string is not null then
      texto_string := texto_string || 'e ';
    end if;
    if substr(tres_digitos, 2, 1) = '2' then
      texto_string := texto_string || 'Vinte ';
    elsif substr(tres_digitos, 2, 1) = '3' then
      texto_string := texto_string || 'Trinta ';
    elsif substr(tres_digitos, 2, 1) = '4' then
      texto_string := texto_string || 'Quarenta ';
    elsif substr(tres_digitos, 2, 1) = '5' then
      texto_string := texto_string || 'Cinquenta ';
    elsif substr(tres_digitos, 2, 1) = '6' then
      texto_string := texto_string || 'Sessenta ';
    elsif substr(tres_digitos, 2, 1) = '7' then
      texto_string := texto_string || 'Setenta ';
    elsif substr(tres_digitos, 2, 1) = '8' then
      texto_string := texto_string || 'Oitenta ';
    elsif substr(tres_digitos, 2, 1) = '9' then
      texto_string := texto_string || 'Noventa ';
    end if;
    if substr(tres_digitos, 2, 1) = '1' then
      if substr(tres_digitos, 3, 1) <> '0' then
        if substr(tres_digitos, 3, 1) = '1' then
          texto_string := texto_string || 'Onze ';
        elsif substr(tres_digitos, 3, 1) = '2' then
          texto_string := texto_string || 'Doze ';
        elsif substr(tres_digitos, 3, 1) = '3' then
          texto_string := texto_string || 'Treze ';
        elsif substr(tres_digitos, 3, 1) = '4' then
          texto_string := texto_string || 'Catorze ';
        elsif substr(tres_digitos, 3, 1) = '5' then
          texto_string := texto_string || 'Quinze ';
        elsif substr(tres_digitos, 3, 1) = '6' then
          texto_string := texto_string || 'Dezesseis ';
        elsif substr(tres_digitos, 3, 1) = '7' then
          texto_string := texto_string || 'Dezessete ';
        elsif substr(tres_digitos, 3, 1) = '8' then
          texto_string := texto_string || 'Dezoito ';
        elsif substr(tres_digitos, 3, 1) = '9' then
          texto_string := texto_string || 'Dezenove ';
        end if;
      else
        texto_string := texto_string || 'Dez ';
      end if;
    else
      -- Extenso para Unidade
      if substr(tres_digitos, 3, 1) <> '0' and texto_string is not null then
        texto_string := texto_string || 'e ';
      end if;
      if substr(tres_digitos, 3, 1) = '1' then
        texto_string := texto_string || 'Um ';
      elsif substr(tres_digitos, 3, 1) = '2' then
        texto_string := texto_string || 'Dois ';
      elsif substr(tres_digitos, 3, 1) = '3' then
        texto_string := texto_string || 'Tres ';
      elsif substr(tres_digitos, 3, 1) = '4' then
        texto_string := texto_string || 'Quatro ';
      elsif substr(tres_digitos, 3, 1) = '5' then
        texto_string := texto_string || 'Cinco ';
      elsif substr(tres_digitos, 3, 1) = '6' then
        texto_string := texto_string || 'Seis ';
      elsif substr(tres_digitos, 3, 1) = '7' then
        texto_string := texto_string || 'Sete ';
      elsif substr(tres_digitos, 3, 1) = '8' then
        texto_string := texto_string || 'Oito ';
      elsif substr(tres_digitos, 3, 1) = '9' then
        texto_string := texto_string || 'Nove ';
      end if;
    end if;
    if to_number(tres_digitos) > 0 then
      if to_number(tres_digitos) = 1 then
        if ind = 1 then
          texto_string := texto_string || 'Quatrilhão ';
        elsif ind = 2 then
          texto_string := texto_string || 'Trilhão ';
        elsif ind = 3 then
          texto_string := texto_string || 'Bilhão ';
        elsif ind = 4 then
          texto_string := texto_string || 'Milhão ';
        elsif ind = 5 then
          texto_string := texto_string || 'Mil ';
        end if;
      else
        if ind = 1 then
          texto_string := texto_string || 'Quatrilhões ';
        elsif ind = 2 then
          texto_string := texto_string || 'Trilhões ';
        elsif ind = 3 then
          texto_string := texto_string || 'Bilhões ';
        elsif ind = 4 then
          texto_string := texto_string || 'Milhões ';
        elsif ind = 5 then
          texto_string := texto_string || 'Mil ';
        end if;
      end if;
    end if;
    valor_string := valor_string || texto_string;
    -- Escrita da Moeda Corrente
    if ind = 5 then
      if to_number(substr(valor_conv, 16, 3)) > 0 and
         valor_string is not null then
        valor_string := rtrim(valor_string) || ', ';
      end if;
    else
      if ind < 5 and valor_string is not null then
        valor_string := rtrim(valor_string) || ', ';
      end if;
    end if;
    if ind = 6 then
      if to_number(substr(valor_conv, 1, 18)) > 1 then
        valor_string := valor_string || 'Reais ';
      elsif to_number(substr(valor_conv, 1, 18)) = 1 then
        valor_string := valor_string || 'Real ';
      end if;
    
      if to_number(substr(valor_conv, 20, 2)) > 0 and
         length(valor_string) > 0 then
        valor_string := valor_string || 'e ';
      end if;
    end if;
    -- Escrita para Centavos
    if ind = 7 then
      if to_number(substr(valor_conv, 20, 2)) > 1 then
        valor_string := valor_string || 'Centavos ';
      elsif to_number(substr(valor_conv, 20, 2)) = 1 then
        valor_string := valor_string || 'Centavo ';
      end if;
    end if;
  end loop;
  return(rtrim(valor_string));
exception
  when others then
    return('*** VALOR INVALIDO ***');
end;
