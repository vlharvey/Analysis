;General code for creating an .mp4 video using .ps files

; Open the video recorder.
Outpath='/Users/harvey/Desktop/temp/'
video_file = Outpath+'yz_mls_tanom_2013.mp4'; path and name of movie to be created
video = IDLffVideoWrite(video_file, Format='mp4')

;Loop over ps files to be included in video
spawn,'ls '+Outpath+'yz_mls_temp_minus_multiyear_mean_*.png',files0
files=[files0]	;,files1,files2,files3,files4]
for ii = 0L, n_elements(files) -1L do begin
;   spawn,'gs -dBATCH -sDEVICE=png16m -r300 -dNOPAUSE -sOutputFile=movie.png files[ii]'		; convert .ps to .png 
	
	; Read the .png file and add to movie.
 image = Read_PNG(files[ii])
;       Read_JPEG,files[ii],image
        image=reform(image(0:2,*,*))
;dum=image(0,*,*)
;image2=[1b*dum,image]
;image=image2

	if ii eq 0L then begin
		; Configure the video output for the image files to be used for the video
		width = n_elements(image[0,*,0])
		height = n_elements(image[0,0,*]) 
		; Set framerate
		;Note, framerates below 5 may be problematic for some players, instead use the same image for multiple frames as demonstrated below
		framerate = 5 
		stream = video.AddVideoStream(width, height, framerate)
	endif

;	File_Delete,'movie.png'
	; Save the image in the video stream
	for i = 0L, 2L do dum = video -> Put(stream, image); This will use the same image for 3 frames (affect on size is small)
endfor
; Clean things up.
video.Cleanup
end
