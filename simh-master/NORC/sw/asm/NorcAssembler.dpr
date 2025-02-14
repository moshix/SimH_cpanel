program NorcAssembler;
{$APPTYPE CONSOLE}
uses
  SysUtils;

// assembly line format

//          1         2         3         4         5         6
// 123456789012345678901234567890123456789012345678901234567890

// LABEL--- PP OPCODE-- RRRR---- MM SSSS---- MM TTTT---- MM COMMENT

// Label can be up to 8 ascii ident, of NNNN

const MaxSymb = 300;
var fIn, fOut: text;
    bfOut: boolean;
var fname: string;
    Addr: integer = -1;
    nSymb: integer = 0;
    Symb: array[0..MaxSymb] of record
       sName: string;
       Addr: integer;
    end;
    sLin: string;
    nLin: integer;
const
    MaxMne = 15;
    Mne: array[0..MaxMne-1]       of string = ('TR',   'ADD',  'SUB',  'MASK', 'TR SGN', 'STOP',  'TR EQ', 'TR NEQ',
                                               'FADD', 'FSUB', 'FMUL', 'FDIV', 'ABS DIF', 'LOOP', 'NOP' );
    MneOpcode: array[0..MaxMne-1] of integer =( 60,     40,     41,     42,     63,       61,      70,      72,
                                                20,     22,     24,     26,     28,       58,      60);

procedure err(sErr: string);
begin
   writeln('Line ', nLin, ': ', sLin);
   writeln('Error: ', sErr);
   close(fIn);
   if (bfOut) then begin
      close(fOut);
      DeleteFile('prog.txt');
   end;
   Halt(1);
end;

function FindSymb(sName: string): integer;
var i: integer;
begin
   for i := 0 to nSymb-1 do begin
      if Symb[i].sName = sName then begin
         result := i;
         exit;
      end;
   end;
   result := -1;
end;

procedure AddSymb(sName: string; Addr: integer);
begin
   if (nSymb > MaxSymb) then err('Too many symbols defined');
   if (FindSymb(sName) >= 0) then err('Symbol '+ sName +' already defined');
   Symb[nSymb].sName := sName;
   Symb[nSymb].Addr  := Addr;
   inc(nSymb);
end;

function sT(sLin: string; n, l: integer): string;
begin
    sT := Trim(UpperCase(Copy(sLin, n, l)));
end;

function sN(s: string): integer;
var n, Code: integer;
begin
   Val(s, n, code);
   if code = 0 then result := n
               else result := -1;
end;

function ToS(d, len: integer): string;
var s: string;
    n: integer;
begin
   s := '';
   while (len>0) do begin
      n := d mod 10; d := d div 10;
      s := chr(n + ord('0')) + s;
      dec(len);
   end;
   result := s;
end;

function sAddr(s: string): integer;
var n, Code: integer;
begin
   if (s = '*') then begin
      result := Addr;  // current addr
      exit;
   end;
   if (s = '') then begin
      result := 0;  // blank is interpreted as zero
      exit;
   end;
   Val(s, n, code);
   if code = 0 then begin
      result := n;  // is a number
      exit;
   end;
   // is a symbol
   n := FindSymb(s);
   if n < 0 then err('Symbol ' + s + ' not defined');
   result := Symb[n].Addr;
end;

function sMod(s: string): integer;
begin
   result := 0;
   if (s = '') then exit;
   if (length(s) <> 3) or
      (copy(s,1,2)<>'+M') or
      ((s[3]<>'4') and (s[3]<>'6') and (s[3]<>'8')) then err('Modifier is ' + s + ' but should be +M4, +M6 or +M8');
   result := (ord(s[3]) - ord('0')) * 1000;
end;

procedure parse;
var sLabel, sOpCode, sRR, sSS: string;
    nLabel, nR, nN: integer;
begin
    sLabel  := sT(sLin,  1, 8);
    sOpCode := sT(sLin, 13, 8);
    if (sOpCode = '') and (sLabel='') then exit; // blank line
    if (sLabel = 'LABEL---') then exit;
    if (Copy(sLabel,1,1) = ';') then exit; // comment line
    nLabel  := sN(sLabel);
    sRR     := sT(sLin, 22, 8);
    nR      := sN(sRR);
    sSS     := sT(sLin, 34, 8);

    if sLabel = '' then begin
       // label not present
       if (Addr < 0) then err('No current addr defined');
    end else begin
       // label present
       if (nLabel >= 0) then begin
          Addr := nLabel; // numeric label sets current addr
       end else if sOpCode = 'EQU' then begin
          // LABEL   EQU   NNNN   - set label to NNNN
          // LABEL   EQU   LABEL  [NNNNN]  - set label to exiting label optionally + nnnn
          nR := sAddr(sRR);
          nN := sN(sSS);
          if nN > 0 then begin
             nR := nR + nN;
             if (nR >= 10000) then nR := nR - 10000;
          end;
          AddSymb(sLabel, nR);
       end else begin
          if (Addr < 0) then err('No current addr defined');
          // alpha Label gets PC value
          AddSymb(sLabel, Addr);
       end;
    end;
    if sOpCode = 'RES' then begin
       // LABEL   RES   NNNN   - reserve space
       if (nR < 1) then err('Amount of mem to reserve not numeric');
       Addr := Addr + nR;
    end else begin
       Addr := Addr + 1;
    end;

end;

function generate: string;
var sLabel, sPP, sOpCode, sRR, sRMod, sSS, sSMod, sTT, sTMod, sComment: string;
    nLabel, nPP, nOpCode, nR, nS, nT: integer;
    incAddr, m: integer;
begin
   sLabel   := sT(sLin,  1, 8);
   sPP      := sT(sLin, 10, 2);
   sOpCode  := sT(sLin, 13, 8);
   sRR      := sT(sLin, 22, 8);
   sRMod    := sT(sLin, 30, 3);
   sSS      := sT(sLin, 34, 8);
   sSMod    := sT(sLin, 42, 3);
   sTT      := sT(sLin, 46, 8);
   sTMod    := sT(sLin, 54, 3);
   sComment := sT(sLin, 58, 200);

   if (sOpCode = '') and (sLabel='') then begin // comment line
      result := '';
      exit;
   end;
   if (sLabel = 'LABEL---') then begin // blank line
      result := '<SKIP>';
      exit;
   end;
   if (Copy(sLabel,1,1) = ';') then begin // comment line
      result := '';
      exit;
   end;


    if sLabel = '' then begin
       // label not present
       if (Addr < 0) then err('No current addr defined');
    end else begin
       // label present
       if sOpCode = 'EQU' then begin
          // LABEL   EQU   - set label
          result := '';
          exit;
       end;
       nLabel:=sAddr(sLabel);
       Addr := nLabel; // numeric label / symbolic label sets current addr
    end;
    if sOpCode = 'RES' then begin
       // LABEL   RES   NNNN   - reserve space
       incAddr := sN(sRR);
       sPP := '00'; sOpCode := '00'; sRR := '0000'; sSS := '0000'; sTT := '0000';
       sRMod := ''; sSMod := ''; sTMod := '';
    end else begin
       incAddr := 1;
    end;
    // convert opcode mnemonic to instrction code
    if sOpCode = '' then begin
       nOpCode := 0;
    end else begin
       nOpCode := -1;
       for m:=0 to MaxMne-1 do begin
          if (sOpCode <> mne[m]) then continue;
          nOpCode := MneOpcode[m];
          break;
       end;
       if (nOpCode < 0) then begin
          nOpCode := sN(sOpCode);
          if nOpCode < 0 then err('Opcode value '+sOpCode+' is invalid');
       end; 
    end;

    if (sPP='') then nPP := 0 else begin
       nPP  := sN(sPP);
       if (nPP < 0) then err('PP value '+sPP+' is not numeric');
    end;

    nR      := sAddr(sRR);
    m       := sMod(sRMod); if m>0 then inc(nR, m);
    nS      := sAddr(sSS);
    m       :=sMod(sSMod); if m>0 then inc(nS, m);
    nT      := sAddr(sTT);
    m       :=sMod(sTMod); if m>0 then inc(nT, m);

    Result := ToS(Addr, 4) + ' ' +
              ToS(nPP,2) + ' ' + ToS(nOpCode,2) + ' ' +
              ToS(nR,4) + ' ' + ToS(nS,4) + ' ' + ToS(nT,4);

    Addr := Addr + IncAddr;
end;

var s, sPad: string;
begin
  bfOut:=false;
  sPad := '';
  for nLin:=1 to 30 do sPad := sPad + ' ';
  fname:=ParamStr(1);
  if fname='' then begin
     writeln('Missing source file name');
     halt(1);
  end;
  DeleteFile('prog.txt');
  assign(fIn, fname);
  reset(fIn);
  nLin:=0; Addr := -1;
  writeln('Pass 1');
  while not eof(fIn) do begin
     inc(nLin);
     readln(fIn, sLin);
     parse;
  end;
  reset(fIn);
  nLin:=0; Addr := -1;
  assign(fOut, 'prog.txt');
  rewrite(fOut);
  bfOut:=true;
  writeln('Pass 2');
  while not eof(fIn) do begin
     inc(nLin);
     readln(fIn, sLin);
     s := generate;
     if s = '<SKIP>' then continue;
     if s = '' then s := sPad;
     s := s + '   ' + sLin;
     writeln(fOut, s);
  end;
  close(fIn);
  close(fOut);
end.
