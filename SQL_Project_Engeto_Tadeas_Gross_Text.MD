# Engeto - Projekt z SQL
Autor: Tadeáš Gross

> Tento projekt byl zpracován jako součást kurzu Datová Akademie a jeho cílem je připravit datové podklady pro analýzu vývoje mezd a cen vybraných potravin v České republice. Na základě dostupných dat jsou vytvořeny přehledné tabulky, které umožňují tato data mezi sebou porovnávat v jednotlivých letech.
>
> Projekt pracuje především s daty o mzdách a cenách potravin z tabulky countries. Jako doplňující zdroj jsou využita také makroekonomická data o jednotlivých státech (například HDP, GINI koeficient nebo populace) z tabulky economies.
>
> Projekt vychází z předem definovaných výzkumných otázek, které se zaměřují na vztah mezi vývojem mezd, cen potravin a vybraných ekonomických ukazatelů.

> **Výzkumné otázky:**
>
> 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
>
> 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
>
> 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
>
> 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
>
> 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## Tvorba primary a secondary tabulky

Při tvoření tabulek jsem narazil na několik otázek, které bylo nutné zodpovědět ještě i před hledáním odpovědí na samotné výzkumné otázky. Jelikož byly tabulky poměrně obsáhlé, tak jsem musel rozhodnout které data budou nutné pro splnění projektu. V případě primary tabulky jsem se rozhodl pro unikátní identifikátor, rok záznamu, hodnotu záznamu (korunovou), název záznamu, typ záznamu a jednotku za kterou je cena vyjádřena v případě potravin. Poté u secondary tabulky jsem se rozhodl pro unikátní identifikátor, název země, rok záznamu, HDP, gini a populaci.

Další komplikace nastala při samotných datech, které měli být přítomné v primary tabulce. Měli jsme sem importovat jak hodnoty mezd, tak hodnoty cen potravin, což intuitivně vedlo k tvorbě dvou tabulek, ale zadání jasně omezovalo na tabulku pouze jednu. Bylo tedy nutné tyto data nějak spojit do jedné tabulky. Rozhodl jsem se pro spojení těchto dat pomocí UNION a rozlišení o který jde záznam podle již zmíněného typu záznamu, který může nabýt hodnot food nebo wage. Hodnota záznamu pak nabývala hodnoty buď ceny potraviny, nebo výšky mzdy a název buď název potraviny nebo název oboru.

Poslední rozhodnutí bylo zda data nějakým způsobem agregovat. Záznamů bylo poměrně dost a na všechny výzkumné otázky byly potřeba průměry a ne nutně konkrétní jeden záznam. Data byly tedy zprůměrovány tak, aby měl vždy jeden konkrétní typ potraviny/mzdy pouze jeden záznam za konkrétní rok.

SQL příkaz pro tvorbu tabulek a insert dat jsou dostupné v SQL souboru v tomto repozitáři.

## Odpovědi na výzkumné otázky

Odpovědi přímo vycházejí z výsledků SELECT statementů, které jsou přítomné v SQL souboru v tomto repozitáři.

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

Ve všech odvětvích od prvního do posledního sledovaného období mzda vzrostla. V některých obdobích jsou však meziroční poklesy. Celkově jsou ale meziroční změny z výrazné většiny pozitivní.

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

V roce 2006 za průměrnou mzdu ze všech odvětví bylo možné koupit ≐ 1437 litrů mléka a ≐ 1287 kilogramů chleba. V roce 2018 bylo možné znova za průměrnou mzdu ze všech odvětví koupit ≐ 1642 litrů mléka a ≐ 1342 kilogramů chleba. V selectu lze vidět i dostupnost chleba a mléka v různých sledovaných odvětvích.

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

Z prvního selectu lze vidět jednotlivé meziroční zdražení. Druhý select bere průměrné zdražování/zlevňovaní ze všech sledovaných období, kde vychází, že nejvíce zlevnil cukr a nejméně zdražili banány.

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

Z obou pohledů na otázku je odpověď NE. Meziroční růst potravin nikdy nebyl ani více než 10% a pokud se podíváme na rok 2013, kde byl pokles mezd, tak stejně nebyl rozdíl mezi navýšením potravin a poklesu mezd 10% (byl ≐ 6,78%).

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

Ze sledovaného období nelze určit jasnou korelaci HDP a cen potravin/mezd. Určité roky (např. 2009) lze vidět možnou reakci cen na vývoj HDP, ale stále je sledované období moc krátké na jasné určení korelace. I z principu ukazatelů by bylo očekávatelné, že budou tyto hodnoty na sebe reagovat se zpožděním, nebo na sebe nemusí nutně reagovat vůbec.
