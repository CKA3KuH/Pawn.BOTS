Ovo je skripta za plugin "pawnbots". Omogućava automatsko podešavanje sata online prisustva botova.

**Prednosti:**

Neće izbacivati botove i igrače. Botovi zauzimaju slote. Botovi imaju RP nadimke, nasumične nivoe, boje (skinove) i ping. Omogućeno je dodavanje/uklanjanje botova iz igre.

**Instalacija:**

Raspakujte Pawn.BOTS u folder vašeg servera i uredite server.cfg:

Dodajte pawnbots na kraj svih filterscripts.
Dodajte pawnraknet.so i pawnbots.so na kraj svih plugins.
Proverite da li vrednost maxnpc u server.cfg nije 0, jednostavno postavite maxnpc 1. Dodajte #include odmah posle #include <a_samp>, i kompajlirajte mod.
**Podešavanje:**

Komanda za podešavanje unutar igre je .pbots. Unutar foldera scriptfiles/pawnbots nalazi se 7 fajlova:

admin.inc - lista nadimaka koji mogu koristiti komandu za podešavanje unutar igre.
color.inc - boje (skinovi) za botove.
lvl.inc - nivoi za botove.
nick.inc - nadimci za botove.
ping.inc - ping vrednosti za botove.
online.inc - podešavanje automatskog sata online prisustva botova (ne uređivati ručno).
setting.inc - ostala podešavanja (ne uređivati ručno).
**Napomene:**

Skripta koristi PawnRakNet plugin. Plugin ne postoji za Windows i neće nikada postojati. Hosting provajderi će ili blokirati vas ili zahtevati dodatno plaćanje za dodatni opterećenje, jer svaki bot stvara poseban proces.

*Autor plugina: urShadow*