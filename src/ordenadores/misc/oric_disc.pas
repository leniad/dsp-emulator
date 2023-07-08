unit oric_disc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}disk_file_format,main_engine;

type
  tirq_handler=procedure(valor:byte);
  twd17xx=class
            constructor create(clock:dword);
            destructor free;
          public
            c_drive:byte;           // Currently active drive
            c_side:byte;            // Currently active side
            clock:dword;
            procedure run(cycles:word);
            procedure write(direccion,valor:byte);
            function read(direccion:byte):byte;
            procedure reset;
          private
            r_status:byte;          // Status register
            r_track:byte;           // Track register
            r_sector:byte;          // Sector register
            r_data:byte;            // Data register
            c_track:byte;           // Currently selected track
            c_sector:byte;          // Currently selected sector ID
            sectype:byte;           // When reading a sector, this is used to remember if it was marked as deleted
            distatus:integer;          // The new contents for r_status when delayedint expires (or -1 to leave it untouched)
            delayedint:integer;        // A cycle counter for simulating a delay before INTRQ is asserted
            delayeddrq:integer;        // A cycle counter for simulating a delay before DRQ is asserted
            currentop:byte;         // Current operation in progress
            last_step_in:boolean;      // Set to TRUE if the last seek operation stepped the head inwards
            curroffs:word;          // Current offset into the above sector
            currsector:boolean;        // Pointers to the current sector in the disk image being used by an active read or write operation
            currseclen:word;        // The length of the current sector
            ddstatus:integer;          // The new contents for r_status when delayeddrq expires (or -1 to leave it untouched)
            num:byte;
            crc:word;
            clrintrq:procedure(num:byte);
            setintrq:procedure(num:byte);
            clrdrq:procedure(num:byte);
            setdrq:procedure(num:byte);
            procedure seek_track(track:byte);
            function find_sector(secid:byte):boolean;
            function first_sector:boolean;
            function next_sector:boolean;
          end;
  tmicrodisc=class
               constructor create(clock:dword;set_irq:tirq_handler);
               destructor free;
             public
                rom:array[0..$1fff] of byte;
                port_314:byte;
                irq_handle:tirq_handler;
                wd:twd17xx;
                procedure reset;
                procedure write(direccion,valor:byte);
                function read(direccion:byte):byte;
             private
                intrq,drq:byte;
             end;

const
    P_ROMDIS    =$02;
    P_EPROM     =$80;
    MDSF_INTENA =  1;
    MDSF_INTRQ  =$80;
    WSF_BUSY=$1;
    WSFI_HEADL=$20;
    WSFI_SEEKERR=$10;
    WSFI_PULSE=$2;
    WSFI_TRK0=$4;
    WSF_NOTREADY=$80;
    WSF_RNF=$10;
    WSF_DRQ=2;
    MF_DRQ=$80;
    WSFR_RECTYP=$20;
    COP_NUFFINK=0;      // Not doing anything, guv
    COP_READ_TRACK=1;     // Reading a track
    COP_READ_SECTOR=2;    // Reading a sector
    COP_READ_SECTORS=3;   // Reading multiple sectors
    COP_WRITE_TRACK=4;    // Writing a track
    COP_WRITE_SECTOR=5;   // Writing a sector
    COP_WRITE_SECTORS=6;  // Writing multiple sectors
    COP_READ_ADDRESS=7;  // Reading a sector header

var
  microdisc_0:tmicrodisc;
  disc_count:integer=-1;

implementation
var
  refreshdisks:boolean;

constructor twd17xx.create(clock:dword);
begin
  self.clock:=clock;
  disc_count:=disc_count+1;
  self.num:=disc_count;
end;

destructor twd17xx.free;
begin
  disc_count:=disc_count-1;
end;

function twd17xx.find_sector(secid:byte):boolean;
var
  revs:byte;
begin
  revs:=0;
  find_sector:=false;
  // No disk image? No sectors!
  if not(dsk[self.c_drive].abierto) then exit;
  // No sectors on this track? Someone needs to format their disk...
  if (dsk[self.c_drive].Tracks[self.c_side,self.c_track].number_sector=0) then exit;
  // We do this more realistically than we need to since this is not
  // a super-accurate emulation (for now). Never mind. Lets go
  // around the track up to two times.
  while (revs<2) do begin
    // Move on to the next sector
    self.c_sector:=(self.c_sector+1) mod dsk[self.c_drive].Tracks[self.c_side,self.c_track].number_sector;
    // If we passed through the start of the track, set the pulse bit in the status register
    if (self.c_sector=0) then begin
      revs:=revs+1;
      self.r_status:=self.r_status or WSFI_PULSE;
    end;
    // Found the required sector?
    if (dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].sector=secid) then begin
      find_sector:=true;
      exit;
    end;
  end;
  // The search failed :-(
end;

procedure twd17xx.seek_track(track:byte);
begin
  // Is there a disk in the drive?
  if dsk[self.c_drive].abierto then begin
    // Yes. If we are trying to seek to a non-existant track, just seek as far as we can
    if (track>=dsk[self.c_drive].DiskHeader.nbof_tracks) then begin
      if dsk[self.c_drive].DiskHeader.nbof_tracks>0 then track:=dsk[self.c_drive].DiskHeader.nbof_tracks-1
        else track:=0;
      self.distatus:=WSFI_HEADL or WSFI_SEEKERR;
    end else self.distatus:=WSFI_HEADL or WSFI_PULSE;
    // Update our status
    self.c_track:=track;
    self.c_sector:=0;
    self.r_track:=track;
    // Assert INTRQ in 20 cycles time and update the status accordingly
    // (note: 20 cycles is waaaaaay faster than any real drive could seek. The actual
    // delay would depend how far the head had to seek, and what stepping speed was
    // currently set).
    self.delayedint:=20;
    if (track=0) then self.distatus:=self.distatus or WSFI_TRK0;
    exit;
  end;
  // No disk in drive
  // Set INTRQ because the operation has finished.
  self.setintrq(self.num);
  self.r_track:=0;
  // Set error state
  self.r_status:=WSF_NOTREADY or WSFI_SEEKERR;
end;
function twd17xx.first_sector:boolean;
begin
  first_sector:=false;
  // No disk? no sector...
  if not(dsk[self.c_drive].abierto) then exit;
  // No sectors?!
  if (dsk[self.c_drive].Tracks[self.c_side,self.c_track].number_sector<1) then exit;
  // We're at the first sector!
  self.c_sector:=0;
  self.r_status:=WSFI_PULSE;
  // Return the sector pointers
  first_sector:=false;
end;
function twd17xx.next_sector:boolean;
begin
  next_sector:=false;
  // No disk? no sector...
  if not(dsk[self.c_drive].abierto) then exit;
  // No sectors?!
  if (dsk[self.c_drive].Tracks[self.c_side,self.c_track].number_sector<1) then exit;
  // Get the next sector number
  self.c_sector:=(self.c_sector+1) mod dsk[self.c_drive].Tracks[self.c_side,self.c_track].number_sector;
  // If we are at the start of the track, set the pulse bit
  if (self.c_sector=0) then self.r_status:=self.r_status or WSFI_PULSE;
  // Return the sector pointers
  next_sector:=true;
end;
function calc_crc(crc:word;valor:byte):word;
var
  res:word;
begin
  res:=((crc and $ff00) shr 8) or ((crc and $ff) shl 8);
  res:=res xor valor;
  res:=res xor ((res and $ff) shr 4);
  res:=res xor ((res shl 8) shl 4);
  res:=res xor (((res and $ff) shl 4) shl 1);
  calc_crc:=res;
end;
procedure twd17xx.write(direccion,valor:byte);
var
  ptemp:pbyte;
begin
  case direccion of
    0:begin // Command register
         self.clrintrq(self.num);
         case (valor and $e0) of
              $00:begin  // Restore or seek
                    case (valor and $10) of
                      $00:begin  // Restore (Type I)
                            self.r_status:=WSF_BUSY;
                            if (valor and 8)<>0 then self.r_status:=self.r_status or WSFI_HEADL;
                            self.seek_track(0);
                            self.currentop:=COP_NUFFINK;
                            refreshdisks:=true;
                          end;
                      $10:begin  //Seek (Type I)
                            self.r_status:=WSF_BUSY;
                            if (valor and 8)<>0 then self.r_status:=self.r_status or WSFI_HEADL;
                            self.seek_track(self.r_data);
                            self.currentop:=COP_NUFFINK;
                            refreshdisks:=true;
                          end;
                    end;
              end;
              $20:begin  // Step (Type I)
                    self.r_status:=WSF_BUSY;
                    if (valor and 8)<>0 then self.r_status:=self.r_status or WSFI_HEADL;
                    if self.last_step_in then self.seek_track(self.c_track+1)
                       else if (self.c_track>0) then self.seek_track(self.c_track-1)
                              else self.seek_track(0);
                    self.currentop:=COP_NUFFINK;
                    refreshdisks:=true;
              end;
              $40:begin  // Step-in (Type I)
                    self.r_status:=WSF_BUSY;
                    if (valor and 8)<>0 then self.r_status:=self.r_status or WSFI_HEADL;
                    self.seek_track(self.c_track+1);
                    self.last_step_in:=true;
                    self.currentop:=COP_NUFFINK;
                    refreshdisks:=true;
              end;
              $60:begin  // Step-out (Type I)
                    self.r_status:=WSF_BUSY;
                    if (valor and 8)<>0 then self.r_status:=self.r_status or WSFI_HEADL;
                    if (self.c_track>0) then self.seek_track(self.c_track-1);
                    self.last_step_in:=false;
                    self.currentop:=COP_NUFFINK;
                    refreshdisks:=true;
              end;
              $80:begin  // Read sector (Type II)
                    self.curroffs:=0;
                    self.currsector:=self.find_sector(self.r_sector);
                    if not(self.currsector) then begin
                      self.r_status:=WSF_RNF;
                      self.clrdrq(self.num);
                      self.setintrq(self.num);
                      self.currentop:=COP_NUFFINK;
                      refreshdisks:=true;
                      exit;
                    end;
                    self.currseclen:=1 shl (dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].sector_size+7);
                    self.r_status:=WSF_BUSY or WSF_NOTREADY;
                    self.delayeddrq:=60;
                    if (valor and $10)<>0 then self.currentop:=COP_READ_SECTORS
                      else self.currentop:=COP_READ_SECTOR;
                    self.crc:=$e295;
                    refreshdisks:=true;
              end;
              $a0:begin  // Write sector (Type II)
                    self.curroffs:=0;
                    self.currsector:=self.find_sector(self.r_sector);
                    if not(self.currsector) then begin
                      self.r_status:=WSF_RNF;
                      self.clrdrq(self.num);
                      self.setintrq(self.num);
                      self.currentop:=COP_NUFFINK;
                      refreshdisks:=true;
                      exit;
                    end;
                    self.currseclen:=1 shl (dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].sector_size+7);
                    self.r_status:=WSF_BUSY or WSF_NOTREADY;
                    self.delayeddrq:=500;
                    if (valor and $10)<>0 then self.currentop:=COP_WRITE_SECTORS
                        else self.currentop:=COP_WRITE_SECTOR;
                    self.crc:=$e295;
                    refreshdisks:=true;
              end;
              $c0:begin  // Read address / Force IRQ
                    case (valor and $10) of
                      $00:begin // Read address (Type III)
                            self.curroffs:=0;
                            if not(self.currsector) then self.currsector:=self.first_sector
                              else self.currsector:=self.next_sector;
                            if not(self.currsector) then begin
                              self.r_status:=WSF_RNF;
                              self.clrdrq(self.num);
                              self.currentop:=COP_NUFFINK;
                              self.setintrq(self.num);
                              refreshdisks:=false;
                            end else begin
                              self.r_status:=WSF_NOTREADY or WSF_BUSY or WSF_DRQ;
                              self.setdrq(self.num);
                              self.currentop:=COP_READ_ADDRESS;
                              refreshdisks:=true;
                            end;
                          end;
                      $10:begin // Force Interrupt (Type IV)
                            self.r_status:=0;
                            self.clrdrq(self.num);
                            self.setintrq(self.num);
                            self.delayedint:=0;
                            self.delayeddrq:=0;
                            self.currentop:=COP_NUFFINK;
                            refreshdisks:=true;
                      end;
                    end;
              end;
              $e0:begin  // Read track / Write track
                    case (valor and $10) of
                      $00:begin // Read track (Type III)
                            self.curroffs:=0;
                            self.r_status:=WSF_BUSY or WSF_NOTREADY;
                            self.delayeddrq:=60;
                            self.currentop:=COP_READ_TRACK;
                            refreshdisks:=true;
                          end;
                      $10:begin // Write track (Type III)
                            self.curroffs:=0;
                            self.r_status:=WSF_NOTREADY or WSF_BUSY;
                            self.delayeddrq:=500;
                            self.clrdrq(self.num);
                            self.clrintrq(self.num);
                            self.delayedint:=0;
                            self.currentop:=COP_WRITE_TRACK;
                            refreshdisks:=true;
                          end;
                    end;
              end;
            end;
        end;
    1:self.r_track:=valor;
    2:self.r_sector:=valor;
    3:begin
        self.r_data:=valor;
        case self.currentop of
          COP_WRITE_SECTOR,COP_WRITE_SECTORS:begin
              if not(self.currsector) then begin
                self.r_status:=self.r_status and not(WSF_DRQ);
                self.r_status:=self.r_status or WSF_RNF;
                self.clrdrq(self.num);
                self.currentop:=COP_NUFFINK;
                refreshdisks:=true;
                exit;
              end;
              ptemp:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].data;
              inc(ptemp,dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].posicion_data);
              if (self.curroffs=0) then dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].status1:=$fb;
              ptemp[self.curroffs]:=self.r_data;
              self.curroffs:=self.curroffs+1;
              self.crc:=calc_crc(self.crc,self.r_data);
              //if( !wd->disk[wd->c_drive]->modified ) refreshdisks = SDL_TRUE;
              //wd->disk[wd->c_drive]->modified = SDL_TRUE;
              //wd->disk[wd->c_drive]->modified_time = 0;
              self.r_status:=self.r_status and not(WSF_DRQ);
              self.clrdrq(self.num);
              if (self.curroffs>(self.currseclen-1)) then begin
                dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].data_length:=self.crc;
                if (self.currentop=COP_WRITE_SECTORS) then begin
                  // Get the next sector, and carry on!
                  self.r_sector:=self.r_sector+1;
                  self.curroffs:=0;
                  self.currsector:=self.find_sector(self.r_sector);
                  self.crc:=$e295;
                  if not(self.currsector) then begin
                    self.delayedint:=20;
                    self.distatus:=self.sectype;
                    self.currentop:=COP_NUFFINK;
                    self.r_status:=self.r_status and not(WSF_DRQ);
                    self.clrdrq(self.num);
                    refreshdisks:=true;
                    exit;
                  end;
                  self.delayeddrq:=180;
                  exit;
                end;
                self.delayedint:=32;
                self.distatus:=self.sectype;
                self.currentop:=COP_NUFFINK;
                self.r_status:=self.r_status and not(WSF_DRQ);
                self.clrdrq(self.num);
                refreshdisks:=true;
              end else self.delayeddrq:=32;
          end;
        end;
      end;
      else halt(0);
  end;
end;

function twd17xx.read(direccion:byte):byte;
var
  ret:byte;
  ptemp:pbyte;
begin
  case direccion of
    0:begin // Status register
        self.clrintrq(self.num);   // Reading the status register clears INTRQ
        ret:=self.r_status;
      end;
    1:ret:=self.r_track; // Track register
    2:ret:=self.r_sector; // Sector register
    3:case self.currentop of
       COP_READ_SECTOR,COP_READ_SECTORS:begin
          // We somehow started a sector read operation without a valid sector.
          if not(self.currsector) then begin
            // Abort.
            self.r_status:=self.r_status and not(WSF_DRQ);
            self.r_status:=self.r_status or WSF_RNF;
            self.clrdrq(self.num);
            self.currentop:=COP_NUFFINK;
            refreshdisks:=true;
            exit;
          end;
          // If this is the first read of a read operation, remember the record type for later
          ptemp:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].data;
          inc(ptemp,dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].posicion_data);
          if (self.curroffs=0) then begin
            if (dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].status1=$f8) then self.sectype:=WSFR_RECTYP
              else self.sectype:=0;
          end;
          // Get the next byte from the sector
          self.r_data:=ptemp[self.curroffs];
          self.curroffs:=self.curroffs+1;
          self.crc:=calc_crc(self.crc,self.r_data);
          // Clear any previous DRQ
          self.r_status:=self.r_status and not(WSF_DRQ);
          self.clrdrq(self.num);
          // Has the whole sector been read?
          if (self.curroffs>(self.currseclen-1)) then begin
            // If you want to do CRC checking, wd->crc should equal (wd->currsector->data_ptr[wd_curroffs]<<8)|wd->currsector->data_ptr[wd_curroffs+1] right here
            // We've got to the end of the current sector. IF it is a multiple sector
            // operation, we need to move on!
            if (self.currentop=COP_READ_SECTORS) then begin
              // Get the next sector, and carry on!
              self.r_sector:=self.r_sector+1;
              self.curroffs:=0;
              self.currsector:=self.find_sector(self.r_sector);
              self.crc:=$e295;
              // If we hit the end of the track, thats fine, it just means the operation
              // is finished.
              if not(self.currsector) then begin
                self.delayedint:=20;           // Assert INTRQ in 20 cycles time
                self.distatus:=self.sectype;  // ...and when doing so, set the status to reflect the record type
                self.currentop:=COP_NUFFINK;   // No longer in the middle of an operation
                self.r_status:=self.r_status and not(WSF_DRQ);    // Clear DRQ (no data to read)
                self.clrdrq(self.num);
                refreshdisks:=true;       // Turn off the disk LED in the status bar
                exit;
              end;
              // We've got the next sector lined up. Assert DRQ in 180 cycles time (simulate a bit of a delay
              // between sectors. Note that most of these values have been pulled out of thin air and might need
              // adjusting for some pickier loaders).
              self.delayeddrq:=180;
              exit;
            end;
            // Just reading one sector so..
            self.delayedint:=32;           // INTRQ in a little while because we're finished
            self.distatus:=self.sectype;  // Set the status accordingly
            self.currentop:=COP_NUFFINK;   // Finished the op
            self.r_status:=self.r_status and not(WSF_DRQ);    // Clear DRQ (no more data)
            self.clrdrq(self.num);
            refreshdisks:=true;       // Turn off disk LED
          end else begin
            self.delayeddrq:=32;           // More data ready. DRQ to let them know!
          end;
          ret:=self.r_data;
       end;
       COP_READ_ADDRESS:begin
          if not(self.currsector) then begin
            self.r_status:=self.r_status and not(WSF_DRQ);
            self.clrdrq(self.num);
            self.currentop:=COP_NUFFINK;
            refreshdisks:=true;
            exit;
          end;
          //Quiere leer los valores del track...
          case self.curroffs of
              0:begin
                 self.r_sector:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].track;
                 self.r_data:=self.r_sector;
              end;
              1:self.r_data:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].head;
              2:self.r_data:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].sector;
              3:self.r_data:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].sector_size;
              4:self.r_data:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].data_length shr 8;
              5:self.r_data:=dsk[self.c_drive].Tracks[self.c_side,self.c_track].sector[self.c_sector].data_length and $ff;
          end;
          self.curroffs:=self.curroffs+1;
          self.r_status:=self.r_status and not(WSF_DRQ);
          self.clrdrq(self.num);
          ret:=self.r_data;
          if (self.curroffs>=6) then begin
            self.delayedint:=20;
            self.distatus:=0;
            self.currentop:=COP_NUFFINK;
            refreshdisks:=true;
          end else begin
            self.delayeddrq:=32;
          end;
        end;
       else halt(0);
    end;
  end;
read:=ret;
end;

procedure twd17xx.reset;
begin
  self.r_status:=0;
  self.r_track:=0;
  self.r_sector:=0;
  self.r_data:=0;
  self.c_drive:=0;
  self.c_side:=0;
  self.c_track:=0;
  self.sectype:=0;
  self.c_sector:=0;
  self.last_step_in:=false;
  self.currentop:=COP_NUFFINK;
  self.delayedint:=0;
  self.delayeddrq:=0;
  self.distatus:=-1;
  self.ddstatus:=-1;
  refreshdisks:=true;
  self.curroffs:=0;          // Current offset into the above sector
  self.currsector:=false;        // Pointers to the current sector in the disk image being used by an active read or write operation
  self.currseclen:=0;        // The length of the current sector
  self.crc:=0;
end;

procedure twd17xx.run(cycles:word);
begin
  // Is there a pending INTRQ?
  if (self.delayedint>0) then begin
    // Count down the INTRQ timer!
    self.delayedint:=self.delayedint-cycles;
    // Time to assert INTRQ?
    if (self.delayedint<=0) then begin
      // Yep! Stop timing.
      self.delayedint:=0;
      // Need to update the status register?
      if (self.distatus<>-1) then begin
        // Yep. Do so.
        self.r_status:=self.distatus;
        self.distatus:=-1;
      end;
      // Assert INTRQ (this function pointer is set up by the microdisc/jasmin/whatever controller)
      self.setintrq(self.num);
    end;
  end;
  // Is there a pending DRQ?
  if (self.delayeddrq>0) then begin
    // Count down the DRQ timer!
    self.delayeddrq:=self.delayeddrq-cycles;
    // Time to assert DRQ?
    if (self.delayeddrq<=0) then begin
      // Yep! Stop timing.
      self.delayeddrq:=0;
      // Need to update the status register?
      if (self.ddstatus<>-1) then begin
        // Yep. Do so.
        self.r_status:=self.ddstatus;
        self.ddstatus:=-1;
      end;
      // Assert DRQ
      self.r_status:=self.r_status or WSF_DRQ;
      self.setdrq(self.num);
    end;
  end;
end;

//microdisc
procedure clear_drq_int(num:byte);
var
  md:tmicrodisc;
begin
  case num of
    0:md:=microdisc_0;
  end;
  md.drq:=MF_DRQ;
end;
procedure set_drq_int(num:byte);
var
  md:tmicrodisc;
begin
  case num of
    0:md:=microdisc_0;
  end;
  md.drq:=0;
end;
procedure clear_int_irq(num:byte);
var
  md:tmicrodisc;
begin
  case num of
    0:md:=microdisc_0;
  end;
  md.intrq:=MDSF_INTRQ;
  md.irq_handle(CLEAR_LINE);
end;

procedure set_int_irq(num:byte);
var
  md:tmicrodisc;
begin
  case num of
    0:md:=microdisc_0;
  end;
  md.intrq:=0;
  if (md.port_314 and MDSF_INTENA)<>0 then md.irq_handle(ASSERT_LINE);
end;

constructor tmicrodisc.create(clock:dword;set_irq:tirq_handler);
begin
  self.wd:=twd17xx.create(clock);
  self.irq_handle:=set_irq;
  self.wd.clrintrq:=clear_int_irq;
  self.wd.setintrq:=set_int_irq;
  self.wd.clrdrq:=clear_drq_int;
  self.wd.setdrq:=set_drq_int;
end;

destructor tmicrodisc.free;
begin
  self.wd.free;
end;

procedure tmicrodisc.reset;
begin
  self.port_314:=0;
  self.intrq:=0;
  self.drq:=0;
  self.wd.reset;
end;

procedure tmicrodisc.write(direccion,valor:byte);
begin
case (direccion and $f) of
  0..3:self.wd.write(direccion,valor);
  $4:begin
        self.port_314:=valor;
        self.wd.c_drive:=(valor shr 5) and $3;
        self.wd.c_side:=(valor and $10) shr 4;
        if @self.irq_handle<>nil then if (((valor and MDSF_INTENA)<>0) and (self.intrq=0)) then self.irq_handle(ASSERT_LINE)
          else self.irq_handle(CLEAR_LINE);
       end;
  $8:halt(0);
end;
end;

function tmicrodisc.read(direccion:byte):byte;
begin
case (direccion and $f) of
  0..3:read:=self.wd.read(direccion);
  4:read:=self.intrq or $7f;
  8:read:=self.drq or $7f;
end;
end;

end.
