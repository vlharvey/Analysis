;----------------------------------------------------------------
;
;    Pro atmos_h5
;
;
; This Program is designed for reading HDF5-based Aura Data
; Files (e.g. OMI Level-2 and MLS & HIRDLS levels 1 and 2 products). 
; However,it can also read other HDF5 based products such as TOMS 
; version8 data. 
; This is an IDL version 6.2 based program, tested on Unix platform.
; It reads an HDF-EOS5 or HDF5 based data file, and creates binary or
; ascii file for the specific parameter selected by the user.   
; Some times user may not have x-window capability, or user may
; not be interested in displaying an image, as a default this
; program always produces a quicklook image in the background ;
; but an image on the screen is produced only if the user selects
; the display option. Also for entering the input file name
; user has an option of using a dialogue box or enter it using the
; keyboard. HDF files usually have very long names since this
; program does not extract any part of the file-name for any
; logic, user may rename original files to a file name consisting
; of only few characters. 

; The objective of developing this program has been to give a
; very simple code (consisting of few basic HDF commands) to
; the user. This will not only serve the purpose of extracting the
; specific parameter but also if user needs they can use this
; code to insert in their algorithms.
;
; This program creates a Log.txt file which contains some useful informations
;
; This program has been tested on Unix, it should work on other platforms
; if anyproblem please let me know ahmad@daac.gsfc.nasa.gov

; To run this program, simply go in IDL session and then type:
;
;  IDL>   .run atmos_h5.pro
;  IDL>    atmos_h5
;
; ------------------------ 
;
; For suggestions or comments please contact
;
; Dr. Suraiya Ahmad 
; Goddard DAAC, NASA/GSFC
; 301-614-5284 
; email:ahmad@daac.gsfc.nasa.gov
;
; Latest Version:
; Feb  21, 2006'(revision was related to a four dimentional array,input comment was misleading)
; Sept 27,2005 (fixed color bar labels for MLS quicklook)
; May  11,2005 (first version)
;
;------------------------------------------------------------------


PRO ListH5Directory,infile,file_id
;------------------------------------

;Open HDF5-based file
file_id=H5F_OPEN(infile)
;
nswaths= H5G_GET_NMEMBERS(file_id,"/HDFEOS/SWATHS")

print,' '
print,'------------------'
print,'number of swaths= ', nswaths
print,'--------------'
printf,20,'number of swaths= ', nswaths
;
for j=0,nswaths-1 do begin

swathname=' '
swathname=H5G_GET_MEMBER_NAME(file_id,"/HDFEOS/SWATHS",j)
print,'Swath Number ',j+1,'.  swathname= ', swathname
printf,20,'Swath Number ',j+1,'.  swathname= ', swathname
path="/HDFEOS/SWATHS/"+swathname+"/"
n1=H5G_GET_NMEMBERS(file_id,path)
print,'The path:  ',path,'  contains following Groups:'
printf,20,'The path:  ',path,'  contains following Groups:'

for i=0,n1-1 do begin
m1=H5G_GET_MEMBER_NAME(file_id,path,i)
print,i+1,'.   ',m1
printf,20,i+1,'.   ',m1
endfor
print,'----------------'

endfor

return
end


PRO SelectSwath,nx,swathname,n1members,file_id,alon,alat
;----------------------------------------------

;Select Swath, List all members of Data & Geolocation Fields of selected swath 
;
dum=' '
nswaths= H5G_GET_NMEMBERS(file_id,"/HDFEOS/SWATHS")
nthswath=1
if(nswaths gt 1)then begin
print,'For processing, please enter the swath number:'
read,nthswath
endif
swathname=H5G_GET_MEMBER_NAME(file_id,"/HDFEOS/SWATHS",nthswath-1)

;------------
;List Data Fields Parameters

path1="/HDFEOS/SWATHS/"+swathname+"/Data Fields"
print,'Data Field Path:',path1
printf,20,'Data Field Path:',path1
n1members=H5G_GET_NMEMBERS(file_id,path1)
n1start=0
;
ListParameters,file_id,path1,n1start,n1members
;
;------------
;List Geolocation Parameters 
;(as a default also save geolocation for display)
;
print,' '
path2="/HDFEOS/SWATHS/"+swathname+"/Geolocation Fields"
print,'Geolocation Fields Path: ',path2
printf,20,'Geolocation Fields Path: ',path2
n2members=H5G_GET_NMEMBERS(file_id,path2)
n2start=n1members+0
;
ListParameters,file_id,path2,n2start,n2members
SaveGeolocation,swathname,nx,file_id,alon,alat
;;;;  DisplayOrbit,swathname,nx,file_id,alon,alat
;
return
end


PRO SaveGeolocation,swathname,nx,file_id,alon,alat
;-------------------------------------------------
;
dataname="/HDFEOS/SWATHS/"+swathname+"/Geolocation Fields/Longitude"
   dataset_id0 = H5D_OPEN(file_id,dataname)
   alon = H5D_READ(dataset_id0)
   H5D_CLOSE, dataset_id0
dataname="/HDFEOS/SWATHS/"+swathname+"/Geolocation Fields/Latitude"
   dataset_id0 = H5D_OPEN(file_id,dataname)
   alat = H5D_READ(dataset_id0)
   H5D_CLOSE, dataset_id0
;   
;   dataset_id0 = H5D_OPEN(file_id,"/HDFEOS/SWATHS/"+swathname+"/Data Fields/ColumnAmountO3")
;   ozone = H5D_READ(dataset_id0)
;   H5D_CLOSE, dataset_id0

return
end


PRO ListParameters,file_id,path,ns,n
;-------------------------------------------------------------
;list all data members
;
n=H5G_GET_NMEMBERS(file_id,path)
;print,' '
;print,path

print,' '
print, 'Number of Data Parameters in the above Group = ',n
printf,20, 'Number of Data Parameters in the above  Group = ',n

;
for ii=0,n-1 do begin

	r=H5G_GET_MEMBER_NAME(file_id,path,ii)
	filepath=path+'/'+r
;	print,filepath
;
		dataset_id=H5D_OPEN(file_id,filepath)
		dataspace_id=H5D_GET_SPACE(dataset_id)
		dimensions=H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id)
		datatype_id=H5D_GET_Type(dataset_id)
		datatype=H5T_GET_CLASS(datatype_id)
                databytes=H5T_GET_SIZE(datatype_id)
                databits=8*databytes
;		help
        kk=ii+ns

print,kk,r,databits,datatype,dimensions , $
format='(i0,".",a,t50,i2,"-bit ",a,t70," size: ",5(i0,:,"x"))'

printf,20,kk,r,databits,datatype,dimensions , $
format='(i0,".",a,t50,i2,"-bit ",a,t70," size: ",5(i0,:,"x"))'

;	print,kk,r,datatype,dimensions , format='(i0,". ",a,t53,a,t65," size: ",5(i0,:,"x"))'

		

     H5S_CLOSE,dataspace_id
     H5D_CLOSE,dataset_id

endfor

return

end


PRO RetrieveParameter,file_id,swathname,n1members,ds1name,data1,$
fillindx,sfactor,offset,vrange,parm_units
;------------------------------------------------------------------

;Option of using 'given' Data Field Name
;
ds1_name=" "
;  print, "From the list above, Enter Short Name for the Parameter to be Retrieved:"
;  read, ds1_name 
;  ds1_indx = H5D_OPEN(file_id, ds1_name)  

;Option of using 'given' Data Field Index
   ds1_indx=0
   user_indx=0
   print,' '

print, "From the list above, Select & Enter the Index  Number for the  Parameter to be Retrieved:"
read,user_indx

ds1_indx=user_indx
 
if (user_indx LT n1members)then begin                   
	path1="/HDFEOS/SWATHS/"+swathname+"/Data Fields"
	n1members=H5G_GET_NMEMBERS(file_id,path1)

ListAttributeInfo,file_id,path1,ds1_indx,ds1name,data1,fillindx,$
sfactor,offset,vrange,parm_units

endif else begin
	ds1_indx=user_indx-n1members
	path2="/HDFEOS/SWATHS/"+swathname+"/Geolocation Fields"

ListAttributeInfo,file_id,path2,ds1_indx,ds1name,data1,fillindx,$
sfactor,offset,vrange,parm_units

endelse

return
end


PRO ListAttributeInfo,file_id,pathx,ds1_indx,ds1name,data1,fillindx,$
sfactor,offset,vrange,parm_units
;-----------------------------------------------------------------
;
; Retrieve User Requested  Dataset
; Use  Short Name or Index for RETRIEVING Parameter from Data Group

dum=' '
;path1="/HDFEOS/SWATHS/"+swathname+"/Data Fields"
;path2="/HDFEOS/SWATHS/"+swathname+"/Geolocation Fields"

ds1name=h5G_GET_MEMBER_NAME(file_id,pathx,ds1_indx)
filepath=pathx+'/'+ ds1name
;
print,' '

dataset_id1=H5D_OPEN(file_id,filepath)
data1=H5D_READ(dataset_id1)
dataspace_id1=H5D_GET_SPACE(dataset_id1)
dimensions=H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id1)
datatype_id1=H5D_GET_Type(dataset_id1)
datatype=H5T_GET_CLASS(datatype_id1)
databytes=H5T_GET_SIZE(datatype_id1)
databits=8*databytes
print,'------------'
printf,20,'------------'
print,ds1_indx,ds1name,databits,datatype,dimensions , $
format='(i0,".",a,t50,i0,"-bit ",a,t70," size: ",5(i0,:,"x"))'
printf,20,ds1_indx,ds1name,databits,datatype,dimensions , $
format='(i0,".",a,t50,i0,"-bit ",a,t70," size: ",5(i0,:,"x"))'
print,' '
printf,20,' '

;-----------------
;Get attributes
;
attrnum=H5A_GET_NUM_ATTRS(dataset_id1)
n2=attrnum
missingindx=0
fillindx=0

        for jj=0,n2-1 do begin
attrsize=1
attr_id=H5A_OPEN_IDX(dataset_id1,jj)
;attr_id=H5A_OPEN_NAME(dataset_id1,'offset')
attrtype_id=H5A_GET_Type(attr_id)
attrtype=H5T_GET_CLASS(attrtype_id)
databytes=H5T_GET_SIZE(attrtype_id)
databits=8*databytes
attrname=H5A_GET_NAME(attr_id)
attrdims_id=H5A_GET_SPACE(attr_id)
attrdata=H5A_READ(attr_id)

;help,attrname,attrdata,attrtype
;print,attrname,attrdata,attrtype
      
       if(attrname eq 'ValidRange') then begin
       vrange(0)= attrdata
       attrsize=2
       endif
       if(attrname eq 'Units') then parm_units= attrdata
       if(attrname eq 'ScaleFactor')then sfactor(0)= attrdata
       if(attrname eq 'Offset')then offset(0)= attrdata

if(attrname eq 'MissingValue') then begin
missingvalue=attrdata
fill_value=missingvalue
fillindx=1
missingindx=1
endif

if(attrname eq '_FillValue') then begin
 fill_value=attrdata
fillindx=1
endif	

if(attrsize eq 1)then begin
print,jj,dum,attrname,attrdata,databits,attrtype,format='(i0,". ",a,a,":",t35,a,t60,i0,"-bit ",a)'
printf,20,jj,dum,attrname,attrdata,databits,attrtype,format='(i0,". ",a,a,":",t35,a,t60,i0,"-bit ",a)'
endif

if(attrsize eq 2)then begin
print,jj,dum,attrname,attrdata,databits,attrtype,format='(i0,". ",a,a,":",a,t35,a,t60,i0,"-bit ",a)'
printf,20,jj,dum,attrname,attrdata,databits,attrtype,format='(i0,". ",a,a,":",a,t35,a,t60,i0,"-bit ",a)'
endif

endfor
return
end


PRO ConvertData,product,out_buff0,fill_value,vrange,sfactor,offset,out_buff
;----------------------------------------------------------------=====

; Convert data to Geophysical Quantity

rfill_value=float(fill_value)
out_buff=float(out_buff0)


w0=where(out_buff0 eq fill_value,count0)
w1=where(out_buff0 ne fill_value,count1)
;w2=where(out_buff0 gt vrange(1),count2)
;w22=where(out_buff0  ge vrange(0) and out_buff0 le vrange(1),count22)


;---------------------------------
 
 if(count1 gt 0)then begin
 
   if(product eq 'atmos' OR product eq 'other')then begin
     out_buff(w1)=sfactor(0) * ( out_buff(w1)-offset(0) )
    endif
endif

;--------------------------------------------------------------
;Very soon (just before MLS data is made public) the rest of the 
;conversion code below will be tailored tfor Level-1B MLS, HIRDLS 
;and TES Radiance products
;----------------------------------------------------------------

   if(product eq 'aaaa')then begin
    
       out_buff(w1)=sfactor(0) * out_buff(w1)+ offset(0)
        if (s1_name eq  'aaaa') then begin 
         out_buff(w1)=10.^(sfactor(0)* out_buff(w1)+offset(0))   
         endif
    
   endif
;-----------------=====
if(product eq 'aaa')then $ 
       out_buff(w1)=sfactor(0) * out_buff(w1)+ offset(0)

;-----------------=
  if(product eq 'aa')then begin

     nbands=1
     if(ndim gt 2) then nbands=dims(2)
     

   parmindx=0
   print,'enter a processing index for the parameter of interest:'
   print,' 1 for Radiance
   print,' 2 for Reflectances (Not applicable for Emissive Bands)'
   print,' 3 for Corrected Counts'
   print,' 0 for Parameters Other than Above' 
print , ' '

   read,parmindx
   
 if(parmindx eq 0)then begin
    out_buff(w1)=sfactor(0) * ( out_buff(w1)-offset(0) )
    goto, next0
    endif
     
  
   ; Radiances
    if(parmindx eq 1)then begin
       for nb=0,nbands-1  do begin
       out_buff(*,*,nb)=rdfactor(nb) * (out_buff(*,*,nb) - rdoffset(nb))
       endfor
     endif

   ; Reflectances
     if(parmindx eq 2)then begin
        for nb=0,nbands-1  do begin
        out_buff(*,*,nb)= rffactor(nb) * (out_buff(*,*,nb) - rfoffset(nb))
        endfor
      endif
      
 ; Corrected Counts
     if(parmindx eq 3)then begin
      for nb=0,nbands-1  do begin
      out_buff(*,*,nb)=pfactor(nb) * (out_buff(*,*,nb) - poffset(nb))
      endfor
    endif

next0:      
    endif   
;-----------    
;;endif
;-------------------------------------------------------------------------
     

; continue
     if(count0 gt 0)then out_buff(w0)=rfill_value
;    if(count2 gt 0)then out_buff(w2)=rfill_value    
;
print,"---------------------------------------------'
   printf,20,'After converting the numbers to physical quantity:'
   printf,20, 'min and max = ',min(out_buff),max(out_buff)
   print,'After converting the numbers to physical quantity:'
   print,'min and max = ',min(out_buff),max(out_buff)

print,' '
;     print,' Requested Parameter(scaled values), with no mathematical operation applied, is in Array OUT_BUFF0'
;     print,' Requested Data, After Converting to Physical Quantity, is in Array  OUT_BUFF'
;     help,OUT_BUFF0
      help,OUT_BUFF
print,'-----------------------------------------------'
;    print,"REMEMBER!! if there is fill data (may appear here as min value) "
     print, "For the data converted to Physical Quantity (floating variable),' 
     print,' we made sure that no mathematical operation is applied on fill values,'
     print, 'however fill value is saved as a floating-point variable,"
;----------------------------------------------------------

return

end


PRO ExtractBits,s1_name,out_buff0,qflags,flag_id
;-------------------------------------------------------------------------------
;
;Bit extractions of  'good quality data', 'cloud', and 'land/sea' flag info are most needed

;     
       ndim=size(out_buff0,/n_dimensions)
       qdims=size(out_buff0,/dimensions)
       datatype=size(out_buff0,/type)
;
;assuming there are 5 individual quality info that we are interested in
;array qflags will be used to save unpacked quality info, first initialized to 999

       qflags=intarr(qdims(0),qdims(1),5) 
       qflags(*,*,*)=999

;
;Example of OMTO3 Flags are: GroundPixelQualityFalgs, Algorithm Flags, QualityFlags 
;check http://toms.gsfc.nasa.gov/omi/OMTO3FileSpec.fs
;OMTO3 'QualityFlags' consists of 2-bytes (16bits); 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
;combined value of bits '3 2 1 0' contain following info
;if value = 0 (or 8 for descending) then good sample 
; value = 1 (or 9 for descending), data corrected for sun glint contamination
;value = 2,(or 10 for descending) sza > 84 deg 
;

q0123=ISHFT(ISHFT(out_buff0,12),-12)   ; left shifted by 12 bits, then right shifted

     for i=0,qdims(0)-1 do begin
     for j=0,qdims(1)-1 do begin
      
      if (q0123(i,j) eq 0 or q0123(i,j) eq 8 )then qflags(i,j,0)= q0123(i,j); good retrieval

      if (q0123(i,j) eq 1 or q0123(i,j) eq 9)then qflags(i,j,1)= q0123(i,j) ; sunglint corrected

      if (q0123(i,j) eq 2 or q0123(i,j) eq 10)then qflags(i,j,2)= q0123(i,j); solar zenith angle > 84 

     endfor
     endfor

;;again for OMTO3 'QualityFlags' 
;value of Bit8=0(no geolocation error, good ); Bit8=1 (geolocation error)
;value of Bit 9=0 (sza < 88, good value))  if Bit9=1 then sza>88 (bad) 

     qflags(*,*,3)=ISHFT(ISHFT(out_buff0,7),-15) ;geolocation error (0=False, 1= True)
;    qflags(*,*,4)=ISHFT(ISHFT(out_buff0,6),-15)   ; SZA > 88(0=False, 1=True)

print,'Few unpacked flags are saved in the file,  QualityFlags_few_unpacked_flags '
print,' see the function ExtractBit in this program'
printf,20,'Few unpack flags are saved in the file,  QualityFlags_few_unpacked_flags'
printf,20,' see the function ExtractBit of this program'

;qflag0(*,*)=qflags(*,*,0) ;qflag1(*,*)=qflags(*,*,1) 
    ;ww1=where(qflag0 eq 0 and qflag1 eq 1 ,cntg)
    ;(if cntg gt 0) then RecommendedData=out_buff0(ww1) ;out_buff=RecommendedData



return
end


PRO GetStatistic,dat0,dmin,dmax
;----------------------------------------------------------------------
;
;dat0 is test_buff, the max and min will be used in display 

print, 'For quality check: Last three  minima  and top three maxima'
print,' '

printf,20,' '

 printf,20, 'For quality check: Last three  minima and top three maxima'
printf,20,'


min1=0 & min2=0

min1=min(dat0)
print,'Minimum 1= ',min1
printf,20,'Minimum 1= ',min1
w0=where(dat0 gt min1,count0)
min2=min1
if(count0 gt 0)then begin
	min2=min(dat0(w0))
	print,'Minimum 2= ',min2
	printf,20,'Minimum 2= ',min2
	w0=where(dat0 gt min2,count0)
    if(count0 gt 0)then begin
	min3=min(dat0(w0))
	print,'Minimum 3= ',min3
	printf,20,'Minimum 3= ',min3
     endif
endif

;;;;;;;;;;
max1=max(dat0)
print,'            Maximum 1= ',max1
printf,20,'            Maximum 1= ',max1
max2=max1

w0=where(dat0 lt max1,count0)
if(count0 gt 0)then begin
max2=max(dat0(w0))
print,'            Maximum 2= ',max2
printf,20,'            Maximum 2= ',max2
w0=where(dat0 lt max2,count0)
if(count0 gt 0)then begin
max3=max(dat0(w0))
print,'            Maximum 3= ',max3
printf,20,'            Maximum 3= ',max3
endif
endif

dmin=min2
dmax=max2

end


PRO CreateOutput,s1_name,datatype,dims,out_buff,out_buff0,nbinary,nscl
;------------------------------------------------------------------------
;
;Write the extracted data in ASCII or Binary file
;
 
    output_file=" "
print,"------------------------------"

      
       if(nbinary eq 0)then goto, output_asci

       output_file=s1_name+'.bin'
       close,1
       openw,1,output_file
      if(nscl eq 0)then writeu,1,out_buff0
       if(nscl eq 1)then writeu,1,out_buff
       close,1
       print," "

     print,'Your requested data is written in file=   ',output_file
     print,' '

goto, next2
;
output_asci:
     output_file=s1_name+'.asc'
     openw,1,output_file
     if(nscl eq 0)then printf,1,out_buff0
     if(nscl eq 1)then printf,1,out_buff
     close,1
     print," "
     print,'Your requested data is written in file=   ',output_file
     print,' '

next2:
 ;;     if(nscl eq 0 )then print,'NOTE: the output file contains Original data from array OUT_BUFF0 (numbers read from file)'
;;     if(nscl eq 1)then print,'NOTE: the output file contains data from array OUT_BUFF(data after converting into physical quantity)'
     print,"---------------------------- "
  

;
return
end


PRO Subset,out_buff,test_buff,s1_name,subname
;------------------------------------------------------------------------
;
;if parameter is 3 or 4 dimensional, 
;perform channel or layer Subset for the display, 
;also as a default, write the subset data to a file
; name of subset file 's1_name_subset_f6 or _s6 or _t6'
; where 'f' signifies the slice number x from first dimension
; where 's' signifies the slice number x from second dimension
; where 't' signifies the slice number x from third dimension

;------------
ndim=size(out_buff,/n_dimensions)
dims=size(out_buff,/dimensions)
datatype=size(out_buff,/type)
;datatype=4 for floating variable,datatype=1 for byte
rdatatype=datatype

;------------
 
if(ndim gt 2)then begin
 print,'if the parameter buffer (out_buff) contains more than 2 dimensions,'
 print,' select a layer or slice from 3rd (and 4th) dimension for the display'
 print,' as default the file containg subset data will be also created'
 print,' remeber we have already created output file for full data for this parameter  
 endif
print,'-------------------------- '

if(ndim eq 3)then begin
  
   help,out_buff
   print,' the parameter has dimensions:'
   print, dims(0),dims(1),dims(2)
   print,'----------------- '
   print,'for the subset enter the nth channel or nth layer; 
   print,'please use regular numbering scheme starting from 1,  donot use zero,'
   print,'For example, for a slice along 4th layer or channel,'
   print,'for  (slicenum,*,*) enter:  4   9999   9999 '
   print,'for  (*,*,slicenum) enter:  9999   9999   4 '   
   print,'--------------------'
   read,d1,d2,d3
   
   sd1=strtrim(string(d1,format='(i4)'),2)
   sd2=strtrim(string(d2,format='(i4)'),2)
   sd3=strtrim(string(d3,format='(i4)'),2)

  
   if (d1 ne 9999) then begin
    test_buff=make_array(dims(1),dims(2),type=rdatatype)
    test_buff(*,*)=out_buff(d1-1,*,*)
    subname=s1_name+'_'+'subset'+'_f'+ sd1
   endif

  if (d2 ne 9999) then begin
     test_buff=make_array(dims(0),dims(2),type=rdatatype)
     test_buff(*,*)=out_buff(*,d2-1,*)
     subname=s1_name+ '_'+ 'subset'+'_s'+sd2
    endif

   if (d3 ne 9999) then begin
     test_buff=make_array(dims(0),dims(1),type=rdatatype)
     test_buff(*,*)=out_buff(*,*,d3-1)
     subname=s1_name+ '_'+ 'subset'+'_t'+sd3
    endif
   
 
 
 endif

 if(ndim eq 4)then begin
  
   help,out_buff
   print,' the parameter has dimensions:'
   print, '(dims(0),dims(1),dims(2),dims(3))'
   print,' '
   print,'for the subset enter the nth channel or layer or nth slice;'
   print,'please use regular numbering scheme starting from 1,  donot use zero,' 
   print,' For example, for 2nd and 3rd slices along the dimensions'
   print,'other than along the pixel or scanline dimensions' 
   print,'for the parameter with (slicenum1,slicenum2,*,*) enter:  2 3 9999 9999'   
   print,'for the parameter with (*,*,slicenum1,slicenum2) enter:  9999 9999 2 3'
   
   read,d1,d2,d3,d4

   sd1=strtrim(string(d1,format='(i4)'),2)
   sd2=strtrim(string(d2,format='(i4)'),2)
   sd3=strtrim(string(d3,format='(i4)'),2)
   sd4=strtrim(string(d4,format='(i4)'),2)

   
  if (d1 ne 9999 and d2 ne 9999) then begin
    test_buff=make_array(dims(2),dims(3),type=rdatatype)   
    test_buff(*,*)=out_buff(d1-1,d2-1,*,*)
   subname=s1_name+ '_'+'subset'+'_f'+'_'+sd1+'_'+sd2
  endif

  if (d1 ne 9999 and d3 ne 9999) then begin
    test_buff=make_array(dims(1),dims(3),type=rdatatype)
    test_buff(*,*)=out_buff(d1-1,*,d3-1,*)
   subname=s1_name+ '_'+ 'subset'+'_f'+'_'+sd1+'_'+sd3
   endif

  if (d1 ne 9999 and d4 ne 9999) then begin
    test_buff=make_array(dims(1),dims(2),type=rdatatype)
    test_buff(*,*)=out_buff(d1-1,*,*,d4-1)
   subname=s1_name+ '_'+ 'subset'+'_f'+'_'+sd1+'_'+sd4
   endif

  if (d2 ne 9999 and d3 ne 9999) then begin
    test_buff=make_array(dims(0),dims(3),type=rdatatype)
    test_buff(*,*)=out_buff(*,d2-1,d3-1,*)
   subname=s1_name+ '_'+ 'subset'+'_s'+'_'+sd2+'_'+sd3
   endif
  
  if (d2 ne 9999 and d4 ne 9999) then begin
    test_buff=make_array(dims(0),dims(2),type=rdatatype)
    test_buff(*,*)=out_buff(*,d2-1,*,d4-1)
   subname=s1_name+ '_'+ 'subset'+'_s'+'_'+sd2+'_'+sd4
   endif
 
   if (d3 ne 9999 and d4 ne 9999) then begin
    test_buff=make_array(dims(0),dims(1),type=rdatatype)
    test_buff(*,*)=out_buff(*,*,d3-1,d4-1)
   subname=s1_name+ '_'+ 'subset'+'_t'+'_'+sd3+'_'+sd4
   endif
 
   
   
 endif

   sz=size(test_buff,/dimensions)
   print, 'Subset data name=',subname
   printf,20, 'Subset data name=',subname
   printf,20, ' dimensions are:  ' ,sz
   help,subname  

Print, 'quick look image will be created using this subset'   

return
end


PRO DisplayOrbit,swathname,nx,file_id,alon,alat
;-----------------=======
; Display  orbital swath (data coverage) 

w0=where (alat lt -90.0,count0)
if(count0 eq 0 and nx eq 1)then begin
	
	window,1,xsize=400,ysize=200,retain=2,title="Data Coverage"
	map_set,0,0,/moll,/continents,/grid
	;map_grid,latdel=30,londel=60,/box_axes,/label,charsize=1.3
	sz=size(alon)
	nx=sz(1)
	ny=sz(2)
	
	for i=0,ny-1 do begin
		xyouts,alon(0,i),alat(0,i),'.'
		xyouts,alon(nx-1,i),alat(nx-1,i),'.'
	endfor
endif

return
end


PRO DisplayData,s1_name,test_buff,dmin,dmax,xlon,xlat,fill_value,units,flag_id
;-----------------------------------------------------------------------------

s1name=s1_name
ndim=size(test_buff,/n_dimensions)
dims=size(test_buff,/dimensions)
;print,'  Data Array for the quicklook ',s1_name, '=', dims
printf,20,'  Data Array for the quicklook:   ',s1_name, '=', dims
help,test_buff
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;create jpeg/gif image file, and based on user option also display on the screen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
loadct,1 
rr = bytarr(12)
gg = bytarr(12)
bb = bytarr(12)
;      0   1   2   3   4   5   6   7  8   9  10  11
;    blk  blu  g  y   o   r  rust marn blk gry slvr white
rr = [000,065,100,255,255,255,153,128,000,64,128,255]
gg = [000,065,230,255,100,000,000,000,000,64,128,255]
bb = [000,225,100,000,000,000,000,000,000,64,128,255]

tvlct,byte(rr),byte(gg),byte(bb)

;=========================================
;Users option of min and max for the display
;
print,'-------------'
print,'please enter minimum for plot'
print,'avoid using value of Minimum 1, in most cases it is fillvalue'
read,dmin
print,'please enter maximum for plot'
read,dmax

pmin=dmin
pmax=dmax

;................
;  ptitle=" "
;  print,'please enter the Title for the plot'
;  read,ptitle
;  utitle=" "
;try to get units from attribute
;  print,'please enter the units label for the plot'
;  read,utitle

ptitle=s1_name
utitle=units
 
  datalevel=0
  print,'please enter the Product Level number: 1, 2 or 3'
  read,datalevel
;  print,datalevel


;==========================================
nx=0
mmx=800
mmy=600

set_plot,'x'
print,'--------'
print,' '
print,'If you want to display the image on the screen, Type 1 (else type 0)'
read,nx
if(nx eq 0)then goto,nnn

device,pseudo=8,retain=2,decomposed=0
window,2,xsize=600,ysize=400,title=s1_name

goto,mmm

nnn:
set_plot,'z'
device,set_resolution=[mmx,mmy]

mmm:

;----------------
; Linear Plot
;----------------
if(ndim eq 1)then begin
!p.region=[0.0,0.0,1.0,0.9]
title=s1_name+'!c '
  plot,test_buff, psym=-2,xtitle='Data Point', ytitle=s1_name,$
  yrange=[pmin,pmax], charsize=1.5,color=11
;  xyouts,.2,.85,/normal, size=1.5,color=11,charthick=2,s1_name
  ;xyouts,.14,.20,/normal, size=1.0,color=11,charthick=1.5,'Goddard GES DAAC'
  ;xyouts,.17,.16,/normal, size=1.0,color=11,charthick=1.5,'NASA/GSFC'
goto,jp
endif
print,'---------------'

if(ndim gt 1)then begin

ppos=fltarr(4)
ppos(0)=0.1 
ppos(1)=0.1 
ppos(2)=0.8 
ppos(3)=0.8

 

  if(datalevel eq 3)then begin
;      Colorbar1,pmin,pmax,ncolors,units,flag_id
      test_buff=congrid(test_buff,mmx,mmy,/interp)
      testdata=bytscl(test_buff,min=pmin,max=pmax)
     
map_set,0,0,0,/ortho,/grid,/noerase,title=s1_name,position=ppos
      warp=map_image(testdata,startx,starty,xsize,ysize,compress=1)
      tv,warp,startx,starty,xsize=xsize,ysize=ysize,order=1
      map_continents,color=10
      map_grid,color=9
  goto,jp
   endif
     

;-----------------
swath:
;-----------------=

if(ndim EQ 2 and datalevel LT 3)then begin
;
;options of mapped(projected) or unmapped(unprojected) image
;if(size(test_buff,/n_dimensions) eq 2)then goto,mappedimage
goto,mappedimage
;--------
;unmappedimage:
loadct,39
newbuff=test_buff
tvscl,newbuff
xyouts,1,.965,/normal,size=1.7,color=250,charthick=2,'Pressure vs. '+ s1_name
goto,jp
;-----------
mappedimage:
;
image=test_buff
profile=0

;for MLS pressure levels are 37 (29 for cloud ice)
; first one is always surface [0=1000mb; 12=10 mb; 18=1mbar 24=0.1 mbar
;
if (ndim eq 2 and (dims(0) eq 37 or dims(0) eq 29)) then begin
profile=1
s1_name=s1_name+' (10 hPa Level)'
image=test_buff(11,*)
endif

;----------------------
ncolors=7
Colorbar1,pmin,pmax,ncolors,units,flag_id
colmax=ncolors
colmin=1
;-----------------

latmin=min(xlat,max=latmax)
lonmin=min(xlon,max=lonmax)
;;print,' Fill Value=  ',fill_value
print,'lat min and max= ',latmin,latmax
print,'lon min and max= ',lonmin,lonmax
;-------------
sz=size(xlat)
nx=sz(1)
ny=sz(2)
mag=10

;n  xlat=congrid(xlat,mag*nx,mag*ny,/interp)
;n  xlon=congrid(xlon,mag*nx,mag*ny,/interp)
;n  image=congrid(image,mag*nx,mag*ny,/minus_one)
;--------------------
w0=where (xlat gt -90.001,count0)

if(count0 lt 1)then begin
print,' all latitude values are fill_values'
return
endif

latmin=min(xlat(w0))
lonmin=min(xlon(w0))
xlat=xlat(w0)
xlon=xlon(w0)
image=test_buff(w0)

w1=where (image gt fill_value,count1)
if(count1 lt 1)then begin
print,' all numbers are fill_values'
return
endif

latmin=min(xlat(w1))
lonmin=min(xlon(w1))
xlat=xlat(w1)
xlon=xlon(w1)
image=image(w1)


print,'After Taking out Fill_value:'
print, 'Latitude min and max= ',latmin,latmax
print,' Longitude min and max= ',lonmin,lonmax
endif

;-----------

equatorpix=where(fix(xlat) eq 0,cnt)

if (cnt gt 0) then p0lon=xlon(equatorpix(0)) $
else p0lon=-999.9

print,'-------'
print,'Longitude of the first equator crossing pixel is=  ',p0lon  
print,'-------'
fullmap=1
userlatmin=-90.0 
userlonmin=-180.0
userlatmax=90.0
userlonmax=180.0

;;fullmap=0
;;print,'For Mapping, enter your selected region for latmin latmax lonmin lonmax'
;; Print,'For example enter  -20.0 20.0 -160.0 160.0 '
;; read,userlatmin,userlatmax,userlonmin,userlonmax


;p0lat=(userlatmin+userlatmax)/2.
;p0lon=(userlonmin+userlonmax)/2.

p0lat=0.0
p0lon=0.0

if(flag_id gt 0)then goto,Qmap

;--------------
map_set,p0lat,p0lon,/cyl,/continent,/hires,/noerase,/noborder,$
position=ppos,limit=[userlatmin,userlonmin,userlatmax,userlonmax],$
title=s1_name+'!c ',color=11

;==================================================================
;following approach of reprojecting is adopted from 
;Liam Gumley [http://cimss.ssec.wisc.edu/~gumley/]
;and Hermann Mannstein (hmannstein@dlr.de) 
;-----------------------------------
;set number of samples and lines for warped image
ns=!d.x_size
nl=!d.y_size

;------------
;create resampled byte image
p=convert_coord(xlon,xlat,/data,/to_normal) 
newimage=replicate(0B,ns,nl)
newimage(p(0,*)*(ns-1),p(1,*)*(nl-1))=$
bytscl(image,min=pmin,max=pmax,top=colmax-colmin-1)+1B 

;-------------------
;extract portion of image which fits within map boundaries
x=round(!x.window*ns)
y=round(!y.window*nl)
newimage=temporary(newimage( x(0):x(1),y(0):y(1) ) )

;----------------
;compute image offset and sizein device coordinates
p=convert_coord([x(0),x(1)]/float(ns),[y(0),y(1)]/float(nl),$
/normal,/to_device)
xoffset=p(0,0)
yoffset=p(1,0)
xsize=p(0,1)-p(0,0)+1
ysize=p(1,1)-p(1,0)+1

;--------------
;fill holes in resampled image
fill=dilate(newimage,replicate(1,4,4),/gray)
loc=where((fill ge 1B) and (newimage eq 0), count)
if count ge 1 then newimage(loc)=fill(loc)
fill=0
;fill remaining undefined areas of image with the missing value
missing=0B
loc=where(newimage eq 0B,count)
;------------------------
;display resampled image

if (count ge 1) and (missing gt 0B)then newimage(loc)=missing
tv,newimage,xoffset,yoffset,xsize=xsize,ysize=ysize
;-------
;
;draw continents &grid
;
if (fullmap eq 1)then begin
map_continents,color=11
map_grid,latdel=30,londel=60,color=9
;map_grid,/label,latdel=30,latlab=0.0,latalign=0.0,londel=60,lonlab=-90,color=11

endif
;draw frame
plots,[p(0,0),p(0,1)],[p(1,0),p(1,0)],/device
plots,[p(0,1),p(0,1)],[p(1,0),p(1,1)],/device
plots,[p(0,1),p(0,0)],[p(1,1),p(1,1)],/device
plots,[p(0,0),p(0,0)],[p(1,1),p(1,0)],/device
 
endif
goto,jp
;======================================= end of reprojection====

Qmap:

 ww=where((image eq pmin),cntg)
 if(cntg gt 0)then begin  
  map_set,p0lat,p0lon,/cyl,/continent,/hires,/noerase,$
  position=ppos,limit=[userlatmin,userlonmin,userlatmax,userlonmax],$
  title=s1_name+'!c display of flag value='+ strtrim(string(pmin,format='(i4)'),2)
 xyouts,xlon(ww),xlat(ww),'-',color=2
  map_continents
  map_grid
endif

;
;jjjjjjjjjjjjjjjjjjjjj
;
;create jpeg file

;jjjjjjjjjjjjjjjjjjjj

goto,jp


gf:
gif_file=s1name+'.gif'
;wset,1
t=tvrd()
write_gif,gif_file,t
device,/close
print,' '
print, 'GIF file is created :',gif_file
goto,end_imagefile

jp:

jpeg_file=s1name+'.jpg'
;wset,1
tvlct,red,green,blue,/get
;----------------

t=tvrd()
s=size(t)
t3=bytarr(3,s(1),s(2))
t3(0,*,*)=red(t)
t3(1,*,*)=green(t)
t3(2,*,*)=blue(t)

write_jpeg,jpeg_file,t3,true=1
;device,/close
print,' '
print, 'JPEG file is created :',jpeg_file

end_imagefile:

end


PRO Colorbar1,pmin,pmax,ncolors,utitle,flag_id
;--------------------------------------------
;
;create colorbar:

ncolors=7
if(flag_id gt 0)then return

db=fltarr(ncolors)
ds=strarr(ncolors)
abspmax=abs(pmax)

del= (pmax-pmin)/(ncolors-1)
;del=fix((pmax-pmin)/(ncolors-1))

;if(abspmax lt 10 and abspmax gt 0.01 and flag_id eq 0)then begin
;ndel=1000*(pmax-pmin)/(ncolors-1)
;del=fix(ndel)*0.001
;endif

;-----------------
; create color bar
;
for kk=0,ncolors-1 do begin
  db(kk)= (pmin+kk*del)
endfor

;ds=strtrim(string(db),2)

ds=strtrim(string(db,format='(i6)'),2)

if(abspmax lt 100)then ds=strtrim(string(db,format='(f7.1)'),2)
if(abspmax lt 10)then ds=strtrim(string(db,format='(f7.2)'),2)
if(abspmax lt 1)then ds=strtrim(string(db,format='(f7.2)'),2)
if(abspmax le 0.01)then ds=strtrim(string(db,format='(e9.1)'),2)

if(flag_id eq 1)then ds=strtrim(string(db,format='(i5)'),2)

;
;ds=['  0.0','  0.1','  0.2','  0.3','  0.4','  0.5','  0.6']
;ds=['  0.3','  0.6','  0.9','  1.2','  1.5','  1.8']
;
delta=0.1
 for i = 0,ncolors-2 do begin
      ybb = .150 + i*delta
      yee = .250 + i*delta
      ybbz=ybb
   polyfill,[0.85,0.88,0.88,0.85,0.85],[ybb,ybb,yee,yee,ybb],color=i+1,/nor
   xyouts,0.90,ybbz-0.001,align=0,orientation=0,ds(i),/nor
 endfor
xyouts,0.90,yee-0.01,align=0,orientation=0,ds(ncolors-1),/nor
;-------------------
;ptitle=''
;utitle=''
;xyouts,0.12,0.85,ptitle,charsize=2,/nor

xyouts,0.84,.78,utitle,charsize=1.2,/nor

;-----------------

return
end


PRO atmos_h5
;-----------

print,' '
print,' '
   close,20
   openw,20,'log.txt'
;
  nf=0
  
;  print,'Program is designed to read Aura Atmospheric Products'
;  print, ' Please Enter' 
;  print,'  1  For reading MLS Level 1B Radiance Products '
;  print,'  2  For Level-2 & 3 OMI, MLS, HIRDLS or TES Products'
;  print,'  3  For Any Other HDF5 based Products' 
; read,nf

nf=2

if(nf eq 1)then product='L1B' 
if(nf eq 2)then product='atmos'
if(nf eq 3)then product='other'  
;satellite='aura'

;--------------------
; Read 'file name' 
  infile=" "

  nx=0
  print,'If you have x-window and want to use dialogue box for entering file name'
  print,' please Type 1 (else type 0 )'
  read,nx

; Use a filename dialogue box 
  if (nx eq 1) then begin
  infile = dialog_pickfile()
  goto, start
  endif
 
;xx  print," "
  print, "Please Enter Input File Name"
 print, "If file is not in this directory, please use full directory path"
  print," "
  read,infile
;
;----------------
start:
  print,'your input file is:   ',infile	
  printf,20,'your input file is:   ',infile

;----------------------
;Test inputfile for data format 
;(HDF4 or HDF5)
;
;Check file for the HDF5 format?
result=H5F_IS_HDF5(infile)

;-------
if (result ge 1)then begin
ListH5Directory,infile,file_id
endif
;------------------------
;
;else 
;Check file for the HDF4 format
; result=HDF_ISHDF(infile)
;if (result ge 1)then goto, ListH4Directory ;(old atmos code)
;goto,done
;endif
;
;----------------------------
; Retrieve User Requested  Parameter

Next:
;-----------
;select swath, list parameters

SelectSwath,nx,swathname,n1members,file_id,xlon,xlat

;----------
;Initialize variables 

  missingvalue=-666.0
  fill_value=-666.0
  vrange=intarr(2)
  vrange(*)=-9999
  parm_units='none'
  offset=fltarr(200)
  sfactor=fltarr(200)
  offset(*)=0.0
  sfactor(*)=1.0
  parmindx=0
  nbands=1
  flag_id=0
  nscl=0
  nout=0
  nbinary=1
  con=1
;---------
   
;;     print,'If you want to save this retrieved parameter in a file, type 1 (else type 0):'
;;     read,nout
       
       nout=1

       if (nout eq 1)then begin
;;       print,' The default is original values'
;;       print,' scale & offset values are written in file log.txt'
    
;;      print,'If you want to save parameter in the file After converting the numbers to physical quantity , type 1 (else type 0):'
;;      read,nscl

        nscl=1
       
       endif
;------------
;Retrive user selected parameter
;
print,'-------------'
RetrieveParameter,file_id,swathname,n1members,ds1name,data1,fillindx,$
sfactor,offset,vrange,parm_units
print,'----------------'
print,' '
print,'if you want to continue, please type 1 (else type 0):  '
read,con
if(con eq 0)then goto,next3
;
 
;------------------------------------------
;    End of Data Retrieval,   Now it is time to use it
   
   s1_name=ds1name
   out_buff0=data1
    print,'Raw Numbers from file for ', s1_name,'  Minimum=',Min(out_buff0),$
'  Maximum=',max(out_buff0)


;print,' Requested parameter(original numbers) is Stored in Array OUT_BUFF0'
;help,out_buff0
;print,' '
  
;---------------   
;   define data type and  working array out_buff

     ndim=size(out_buff0,/n_dimensions)
     dims=size(out_buff0,/dimensions)
     datatype=size(out_buff0,/type)

; Check if data is UINT8 or INT8  array (datatype  eq 1), information may be packed 

flag_id=0

 if(datatype eq 1)then begin
        ns=0
        nscl=0
        nout=1
        nbinary=1
	out_buff=out_buff0
      flag_id=1
      goto,output
    endif

 if (s1_name eq 'QualityFlags' $
 or s1_name eq 'AlgorithmFlags' $ 
 or s1_name eq 'MeasurementQualityFlags' $
 or s1_name eq 'GroundPixelQualityFlags')then begin
flag_id=2
out_buff=out_buff0
goto,output
endif
;----------
ConvertData,product,out_buff0,fill_value,vrange,sfactor,offset,out_buff
;
;---------------------------------------------------------
output:
;
print,'-------------'
       print,'if you want OUTPUT file in ASCII  please type: 0' 
       print,'For binary file, please type 1'
       read,nbinary

;----------------------------------------
;Create output file, 
;
CreateOutput,s1_name,datatype,dims,out_buff,out_buff0,nbinary,nscl 
;
;----------------
      test_buff=out_buff

;test_buff will hold data for display or statistic
;if test_buff have dimensions more than two, 
;two dimensional subset of out_buff will be used as subset
;-----------------------------
Flags:

;Extract Quality Flags 

;List of possible s1_names of quality flags are:
;QualityFlags; AlgorithmFlags; MeasurementQualityFlags; GroundPixelQualityFalgs
;
;if (flag_id eq 2)then begin; ExtractBits,s1_name,out_buff0,qflags;out_buff=qflags ;endif

;-----------------------
; 'qflags' has dimensions (*,*,5), it is an integer array created to hold 
;few (e.g 5) unpacked flags

if (s1_name eq 'QualityFlags') then begin

    ExtractBits,s1_name,out_buff0,qflags,flag_id

    
   out_buff0=qflags
   out_buff=qflags
   FlagsSubsetName=s1_name+'_few_unpacked_flags'
   ndim=size(qflags,/n_dimensions)
   dims=size(qflags,/dimensions)
   s1_name=FlagsSubsetName
   

   CreateOutput,s1_name,datatype,dims,out_buff,out_buff0,nbinary,nscl

endif
;
;-------------------------

;SUBSET
;
;Create a subset of data if dimension is greater than 2
;user will select the slice, final buffer will be of two dimensions 
;subset data will be written to a file and it will be also used for display
print," "

 if(ndim gt 2)then begin

    Subset,out_buff,test_buff,s1_name,subname

     out_buff=test_buff

    CreateOutput,subname,datatype,dims,test_buff,out_buff0,nbinary,nscl

   s1_name=subname

endif
;
;--------------------------
;For quality check: Last three  minima  and top three maxima'
;
   GetStatistic,test_buff,dmin,dmax
;
print,'--------------------'
print,' '
print,'if you want to continue, please type 1 (else type 0):  '
read,con
if(con eq 0)then goto,next3

;-----------------------
;Display Data & create image-file Using Geophysical Quantity
;
print,' For Quick Look Display, we will use subsetted Geophysical data '
;
DisplayData,s1_name,test_buff,dmin,dmax,xlon,xlat,fill_value,parm_units,flag_id
;
;------------------------------
;nc=0
next3:
print,' if you want to continue for another parameter, type 1 (else type 0)'
read,nc
if (nc eq 1)then goto, Next

;---------------------------------------------------------------
done:

close,20

H5F_CLOSE,file_id
;
print,' '
print,' '
print,'Program ended Supessfully'
print,' '
print,' '
print,'----------------------------------------------------------------'
print,' '


print,'you may continue the session with your interactive IDL commands'
print,' IDL command HELP will tell you what you have in memory,  Type: help '

print,' '
print,'----------------------------------------------------------------'

end
