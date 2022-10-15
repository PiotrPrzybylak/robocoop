create table ksl_login_attempts
(
    user_id int         not null,
    time    varchar(30) not null
)
    collate = latin2_general_ci;

create table ksl_users
(
    id          int auto_increment
        primary key,
    username    varchar(30)                           not null,
    email       varchar(50)                           not null,
    password    char(128)                             not null,
    salt        char(128)                             not null,
    first_name  char(50)                              null,
    second_name char(50)                              null,
    phone_no    char(16)                              not null,
    has_license tinyint   default 0                   null,
    timestamp   timestamp default current_timestamp() not null
)
    collate = latin2_general_ci;

create table spoldzielnia_ceny_uzyskane
(
    id          int auto_increment
        primary key,
    id_tury     int            not null,
    id_produktu int            not null,
    cena        decimal(10, 2) not null
)
    collate = latin2_general_ci;

create index id
    on spoldzielnia_ceny_uzyskane (id);

create index id_produktu
    on spoldzielnia_ceny_uzyskane (id_produktu);

create index id_tury
    on spoldzielnia_ceny_uzyskane (id_tury);

create table spoldzielnia_config
(
    aktualna_tura int not null
)
    collate = latin2_general_ci;

create table spoldzielnia_kategorie
(
    id                           int auto_increment
        primary key,
    nazwa                        varchar(255)         not null,
    ukryta                       tinyint(1) default 0 not null,
    okres_blokowania_w_godzinach bigint               null
)
    collate = latin2_general_ci;

create table spoldzielnia_produkty
(
    id                  int auto_increment
        primary key,
    nazwa               varchar(255)          not null,
    jednostka           varchar(50)           not null,
    ilosc_rozliczeniowa int                   not null,
    cena_za_jednostke   decimal(10, 2)        not null,
    kategoria           int                   not null,
    id_zjazdowa         tinyint(2) default 99 not null,
    constraint FK_spoldzielnia_produkty
        foreign key (kategoria) references spoldzielnia_kategorie (id)
)
    collate = latin2_general_ci;

create index id_zjazdowa
    on spoldzielnia_produkty (id_zjazdowa);

create index kategoria
    on spoldzielnia_produkty (kategoria);

create table spoldzielnia_tury_zakupow
(
    id               int auto_increment
        primary key,
    nazwa            varchar(255) not null,
    data_zakonczenia date         null
)
    collate = latin2_general_ci;

create index id
    on spoldzielnia_tury_zakupow (id);

create table spoldzielnia_userzy
(
    id         int auto_increment
        primary key,
    email      varchar(255)                          not null,
    haslo      varchar(255)                          not null,
    nazwisko   varchar(255)                          not null,
    telefon    varchar(50)                           not null,
    czy_prawko int(2)                                not null,
    admin      int(2)                                not null,
    timestamp  timestamp default current_timestamp() not null
)
    collate = latin2_general_ci;

create table spoldzielnia_userzy_old
(
    id         int auto_increment
        primary key,
    email      varchar(255)                          not null,
    haslo      varchar(255)                          not null,
    nazwisko   varchar(255)                          not null,
    telefon    varchar(50)                           not null,
    czy_prawko int(2)                                not null,
    admin      int(2)                                not null,
    timestamp  timestamp default current_timestamp() not null
)
    collate = latin2_general_ci;

create table spoldzielnia_zamowienia
(
    id          int auto_increment
        primary key,
    id_produktu int                                   not null,
    id_tury     int                                   not null,
    id_usera    int                                   not null,
    ilosc       decimal(10, 2)                        not null,
    timestamp   timestamp default current_timestamp() not null,
    constraint FK_spoldzielnia_zamowienia_produkty
        foreign key (id_produktu) references spoldzielnia_produkty (id),
    constraint FK_spoldzielnia_zamowienia_tury
        foreign key (id_tury) references spoldzielnia_tury_zakupow (id),
    constraint FK_spoldzielnia_zamowienia_userzy
        foreign key (id_usera) references spoldzielnia_userzy (id)
)
    collate = latin2_general_ci;

create index NewIndex1
    on spoldzielnia_zamowienia (id_produktu);

create index id_tury
    on spoldzielnia_zamowienia (id_tury);

create index id_usera
    on spoldzielnia_zamowienia (id_usera);

create table spoldzielnia_zjazdowa
(
    id    tinyint(2) auto_increment
        primary key,
    nazwa varchar(25) collate latin2_general_ci not null
)
    collate = utf8_general_ci;

create definer = server400106_1@`%` view ceny_najnowsze as
select `pro`.`id`             AS `id_produktu`,
       `pro`.`nazwa`          AS `nazwa`,
       `pro`.`jednostka`      AS `jednostka`,
       case coalesce((select `cen`.`cena`
                      from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                      where `cen`.`id_produktu` = `pro`.`id`
                        and `cen`.`cena` > 0
                      order by `cen`.`id_tury` desc
                      limit 1), 0)
           when 0 then (select coalesce(`pro`.`cena_za_jednostke`, 0))
           else (select `cen`.`cena`
                 from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                 where `cen`.`id_produktu` = `pro`.`id`
                   and `cen`.`cena` > 0
                 order by `cen`.`id_tury` desc
                 limit 1) end AS `cena`,
       case coalesce((select `cen`.`cena`
                      from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                      where `cen`.`id_produktu` = `pro`.`id`
                        and `cen`.`cena` > 0
                      order by `cen`.`id_tury` desc
                      limit 1), 0)
           when 0 then (select 0)
           else (select max(`cen`.`id_tury`)
                 from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                 where `cen`.`id_produktu` = `pro`.`id`
                   and `cen`.`cena` > 0
                 order by `cen`.`id_tury` desc
                 limit 1) end AS `tura`
from `server400106_1`.`spoldzielnia_produkty` `pro`
group by `pro`.`id`
order by `pro`.`nazwa`;

create definer = server400106_1@`%` view ceny_sub as
select `pro`.`id`             AS `id_produktu`,
       case coalesce((select `cen`.`cena`
                      from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                      where `cen`.`id_produktu` = `pro`.`id`
                        and `cen`.`cena` > 0
                      order by `cen`.`id_tury` desc
                      limit 1), 0)
           when 0 then (select coalesce(`pro`.`cena_za_jednostke`, 0))
           else (select `cen`.`cena`
                 from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                 where `cen`.`id_produktu` = `pro`.`id`
                   and `cen`.`cena` > 0
                 order by `cen`.`id_tury` desc
                 limit 1) end AS `cena`,
       case coalesce((select `cen`.`cena`
                      from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                      where `cen`.`id_produktu` = `pro`.`id`
                        and `cen`.`cena` > 0
                      order by `cen`.`id_tury` desc
                      limit 1), 0)
           when 0 then (select 0)
           else (select max(`cen`.`id_tury`)
                 from `server400106_1`.`spoldzielnia_ceny_uzyskane` `cen`
                 where `cen`.`id_produktu` = `pro`.`id`
                   and `cen`.`cena` > 0
                 order by `cen`.`id_tury` desc
                 limit 1) end AS `tura`
from `server400106_1`.`spoldzielnia_produkty` `pro`
group by `pro`.`id`;

create definer = server400106_1@`%` view pakunki as
select `pro`.`nazwa` AS `nazwa`, `usr`.`nazwisko` AS `nazwisko`, `zam`.`ilosc` AS `ilosc`
from ((`server400106_1`.`spoldzielnia_zamowienia` `zam` left join `server400106_1`.`spoldzielnia_userzy` `usr`
       on (`usr`.`id` = `zam`.`id_usera`)) left join `server400106_1`.`spoldzielnia_produkty` `pro`
      on (`pro`.`id` = `zam`.`id_produktu`))
where `zam`.`id_tury` =
      (select `server400106_1`.`spoldzielnia_config`.`aktualna_tura` from `server400106_1`.`spoldzielnia_config`)
order by `pro`.`nazwa`, `zam`.`id`;

create definer = server400106_1@`%` view pakunki_z_kategoriami as
select `pro`.`nazwa` AS `nazwa`, `usr`.`nazwisko` AS `nazwisko`, `zam`.`ilosc` AS `ilosc`, `kat`.`nazwa` AS `kategoria`
from (((`server400106_1`.`spoldzielnia_zamowienia` `zam` left join `server400106_1`.`spoldzielnia_userzy` `usr`
        on (`usr`.`id` = `zam`.`id_usera`)) left join `server400106_1`.`spoldzielnia_produkty` `pro`
       on (`pro`.`id` = `zam`.`id_produktu`)) left join `server400106_1`.`spoldzielnia_kategorie` `kat`
      on (`kat`.`id` = `pro`.`kategoria`))
where `zam`.`id_tury` =
      (select `server400106_1`.`spoldzielnia_config`.`aktualna_tura` from `server400106_1`.`spoldzielnia_config`)
order by `pro`.`nazwa`, `zam`.`id`;

create definer = server400106_1@`%` view podsumowanie as
select `kat`.`nazwa`                                                          AS `kategoria`,
       `pro`.`nazwa`                                                          AS `produkt`,
       `usr`.`nazwisko`                                                       AS `nazwisko`,
       `zam`.`ilosc`                                                          AS `ilosc`,
       `cen`.`cena`                                                           AS `cena`,
       cast(sum(`zam`.`ilosc` * `pro`.`cena_za_jednostke`) as decimal(10, 2)) AS `wartosc`
from (((((`server400106_1`.`spoldzielnia_zamowienia` `zam` left join `server400106_1`.`spoldzielnia_produkty` `pro`
          on (`pro`.`id` = `zam`.`id_produktu`)) join `server400106_1`.`spoldzielnia_config` `cfg`
         on (`cfg`.`aktualna_tura` = `zam`.`id_tury`)) left join `server400106_1`.`spoldzielnia_userzy` `usr`
        on (`usr`.`id` = `zam`.`id_usera`)) left join `server400106_1`.`spoldzielnia_kategorie` `kat`
       on (`kat`.`id` = `pro`.`kategoria`)) left join `server400106_1`.`ceny_sub` `cen`
      on (`pro`.`id` = `cen`.`id_produktu`))
group by `pro`.`nazwa`, `kat`.`nazwa`, `usr`.`nazwisko`, `zam`.`ilosc`, `pro`.`cena_za_jednostke`
order by `kat`.`nazwa`;

create definer = server400106_1@`%` view zamawiajacy_aktualni as
select distinct `server400106_1`.`spoldzielnia_userzy`.`nazwisko` AS `nazwisko`
from (`server400106_1`.`spoldzielnia_zamowienia` left join `server400106_1`.`spoldzielnia_userzy`
      on (`server400106_1`.`spoldzielnia_zamowienia`.`id_usera` = `server400106_1`.`spoldzielnia_userzy`.`id`))
where `server400106_1`.`spoldzielnia_zamowienia`.`id_tury` in
      (select max(`server400106_1`.`spoldzielnia_tury_zakupow`.`id`) from `server400106_1`.`spoldzielnia_tury_zakupow`)
  and `server400106_1`.`spoldzielnia_userzy`.`nazwisko` is not null
order by `server400106_1`.`spoldzielnia_userzy`.`nazwisko`;

create definer = server400106_1@`%` view zamowienia_aktualne as
(
select `usr`.`nazwisko`  AS `Nazwisko`,
       `pro`.`nazwa`     AS `Produkt`,
       `pro`.`jednostka` AS `Jednostka`,
       `zam`.`ilosc`     AS `Ilosc`,
       `kat`.`nazwa`     AS `Kategoria`,
       `cen`.`cena`      AS `Cena`
from ((((`server400106_1`.`spoldzielnia_zamowienia` `zam` left join `server400106_1`.`spoldzielnia_userzy` `usr`
         on (`usr`.`id` = `zam`.`id_usera`)) left join `server400106_1`.`spoldzielnia_produkty` `pro`
        on (`pro`.`id` = `zam`.`id_produktu`)) left join `server400106_1`.`spoldzielnia_kategorie` `kat`
       on (`kat`.`id` = `pro`.`kategoria`)) left join `server400106_1`.`ceny_sub` `cen`
      on (`cen`.`id_produktu` = `pro`.`id`))
where `zam`.`id_tury` =
      (select `server400106_1`.`spoldzielnia_config`.`aktualna_tura` from `server400106_1`.`spoldzielnia_config`));

create definer = server400106_1@`%` view zamowienia_do_pakunkow as
(
select `usr`.`nazwisko`  AS `Nazwisko`,
       `pro`.`nazwa`     AS `Produkt`,
       `kat`.`nazwa`     AS `Kategoria`,
       `cen`.`cena`      AS `Cena`,
       `pro`.`jednostka` AS `Jednostka`,
       `zam`.`ilosc`     AS `Ilosc`
from (((((`server400106_1`.`spoldzielnia_zamowienia` `zam` join `server400106_1`.`spoldzielnia_userzy` `usr`
          on (`usr`.`id` = `zam`.`id_usera`)) join `server400106_1`.`spoldzielnia_produkty` `pro`
         on (`pro`.`id` = `zam`.`id_produktu`)) join `server400106_1`.`spoldzielnia_kategorie` `kat`
        on (`kat`.`id` = `pro`.`kategoria`)) join `server400106_1`.`ceny_sub` `cen`
       on (`cen`.`id_produktu` = `pro`.`id`)) join `server400106_1`.`spoldzielnia_config` `cfg`
      on (`cfg`.`aktualna_tura` = `zam`.`id_tury`))
order by `pro`.`nazwa`, `zam`.`id`);

create
    definer = server400106_1@`%` procedure GetAllPeople(IN strUserName varchar(40), IN strPassword varchar(40),
                                                        OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
	SET @cnt=0;
	SELECT (@cnt:=@cnt+1) AS rownr, usr.id, usr.nazwisko, usr.email, usr.telefon
	FROM spoldzielnia_userzy usr
	ORDER BY usr.nazwisko;
END;

create
    definer = server400106_1@`%` procedure GetCurrentTurnData(IN strUserName varchar(40), IN strPassword varchar(40),
                                                              OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
    SELECT MAX(spoldzielnia_config.aktualna_tura) AS aktualna_tura, spoldzielnia_tury_zakupow.nazwa FROM spoldzielnia_config
    JOIN spoldzielnia_tury_zakupow ON spoldzielnia_tury_zakupow.id = spoldzielnia_config.aktualna_tura;
END;

create
    definer = server400106_1@`%` procedure GetCurrentTurnNumber(IN strUserName varchar(40), IN strPassword varchar(40),
                                                                OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
    SELECT MAX(aktualna_tura) AS aktualna_tura FROM spoldzielnia_config;
END;

create
    definer = server400106_1@`%` procedure GetOrderedProducts(IN strUserName varchar(40), IN strPassword varchar(40),
                                                              IN intTurnNumber int, OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
	SELECT pro.id, pro.nazwa, pro.jednostka, cen.cena, SUM(zam.ilosc) FROM spoldzielnia_zamowienia zam
	JOIN spoldzielnia_produkty pro ON pro.id = zam.id_produktu
	JOIN ceny_najnowsze cen ON pro.id = cen.id_produktu
	WHERE zam.id_tury = intTurnNumber GROUP BY pro.nazwa, pro.jednostka, cen.cena ORDER BY pro.nazwa;
END;

create
    definer = server400106_1@`%` procedure GetOrderingPeople(IN strUserName varchar(40), IN strPassword varchar(40),
                                                             IN intTurnNumber int, OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
	SELECT usr.id, usr.nazwisko
	FROM spoldzielnia_zamowienia zam
	JOIN spoldzielnia_userzy usr ON usr.id = zam.id_usera
	WHERE zam.id_tury = intTurnNumber
	GROUP BY usr.nazwisko;
END;

create
    definer = server400106_1@`%` procedure GetOrders(IN strUserName varchar(40), IN strPassword varchar(40),
                                                     IN intTurnNumber int, OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
    SELECT * FROM spoldzielnia_zamowienia WHERE id_tury = intTurnNumber;
END;

create
    definer = server400106_1@`%` procedure GetOrdersHumanReadable(IN strUserName varchar(40),
                                                                  IN strPassword varchar(40), IN intTurnNumber int,
                                                                  OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
	SET @cnt=0;
	SELECT (@cnt:=@cnt+1) AS rownr, usr.nazwisko, pro.nazwa, pro.id, zam.ilosc, pro.jednostka,
	CASE cen.cena
		WHEN 0 THEN (SELECT COALESCE(pro.cena_za_jednostke, 0))
		ELSE (SELECT cen.cena)
	END AS cena
	FROM spoldzielnia_zamowienia zam
	JOIN spoldzielnia_userzy usr ON usr.id = zam.id_usera
	JOIN spoldzielnia_produkty pro ON pro.id = zam.id_produktu
	JOIN ceny_sub cen ON cen.id_produktu = pro.id
	WHERE zam.id_tury = intTurnNumber;
END;

create
    definer = server400106_1@`%` procedure GetPackagesHumanReadable()
proc_label:BEGIN
	SET @rownum = 0;
	SET @rownum2 = 0;
	SELECT
		
		CASE WHEN wyn.rownum IN
		(
			SELECT pak_id.rownum
			FROM 
			(
				SELECT @rownum := @rownum + 1 AS rownum, pak.*
				FROM (SELECT * FROM pakunki ORDER BY nazwa) AS `pak`
			) `pak_id`
			GROUP BY pak_id.nazwa
		) THEN
			wyn.nazwa
		ELSE
			''
		END AS `nazwa`
		, wyn.nazwisko
		, wyn.ilosc
	FROM
		(
			SELECT pak_id2.*
			FROM 
			(
				SELECT @rownum2 := @rownum2 + 1 AS rownum, pak2.*
				FROM (SELECT * FROM pakunki ORDER BY nazwa) AS `pak2`
			) `pak_id2`
		) AS `wyn`;
END;

create
    definer = server400106_1@`%` procedure GetProductsWithLatestPrices(IN strUserName varchar(40),
                                                                       IN strPassword varchar(40),
                                                                       OUT intIsPasswordCorrect_OUT int)
proc_label:BEGIN
    
    SELECT COUNT(id)
    INTO @intAccountCount
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
    SELECT haslo
    INTO @strPass
    FROM spoldzielnia_userzy
    WHERE nazwisko = strUserName;
    
	CASE
		WHEN @intAccountCount = 0 THEN
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
		WHEN strPassword = @strPass THEN
			SET intIsPasswordCorrect_OUT = -1;
		ELSE
			SET intIsPasswordCorrect_OUT = -99;
			LEAVE proc_label;
	END CASE;
    
	SET @cnt=0;
    SELECT (@cnt:=@cnt+1) AS rownr, cen.id_produktu, cen.nazwa, cen.jednostka, cen.cena, cen.tura FROM ceny_najnowsze cen;
END;


