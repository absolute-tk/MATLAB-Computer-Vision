function ThaiCarPlate
% Main code for Car Plate Reader in BME424 Computer Vision
% By Theekapun Charoenpong

clc
close all;
clear;

% โหลดข้อมูลตัวอักษรและตัวเลขไทยที่เก็บไว้
load('imgfildataThaiLetterNumber.mat');

% ให้ผู้ใช้เลือกไฟล์ภาพ
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);
[~,cc]=size(picture);

% ปรับขนาดภาพให้เป็น 300x500 pixels
picture=imresize(picture,[300 500]);
pictureRGB = picture;

% แปลงเป็นภาพขาวดำถ้าเป็นภาพสี
if size(picture,3)==3
  picture=rgb2gray(picture);
end

% se=strel('rectangle',[5,5]);
% a=imerode(picture,se);
% figure,imshow(a);
% b=imdilate(a,se);

% แปลงเป็นภาพขาวดำแบบ binary
threshold = graythresh(picture);
picture =imcomplement(imbinarize(picture,threshold));

% กำจัดจุดรบกวนขนาดเล็ก
picture = bwareaopen(picture,30);

imshow(picture)
if cc>2000
    picture1=bwareaopen(picture,3500);
else

% แยกส่วนป้ายทะเบียนออกจากพื้นหลัง
picture1=bwareaopen(picture,3000);

end
figure,imshow(picture1)

% แยกส่วนป้ายทะเบียนออกจากพื้นหลัง
picture2=picture-picture1;

figure,imshow(picture2)
picture2=bwareaopen(picture2,200);
figure,imshow(picture2)


% หาขอบเขตของตัวอักษรแต่ละตัว
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');


hold on
pause(1)


% วาดกรอบรอบตัวอักษรที่พบ
for n=1:size(propied,1)
  rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2) 
  % insertShape is another command for inserting shapes in image
end


hold off

% ????????????????????????????????? dilate

% ขยายภาพในแนวนอนเพื่อเชื่อมตัวอักษร
se=strel('rectangle',[1,200]);
ImdiPicture2=imdilate(picture2,se);

figure,imshow(ImdiPicture2);
[Ldi,Nedi]=bwlabel(ImdiPicture2);
final_output=[];


% วนลูปอ่านแต่ละตัวอักษร
    for ndi=1:Nedi
        
        % แยกพื้นที่แต่ละตัวอักษร
        [rdi,cdi] = find(Ldi==ndi);
        pictureArea = picture2(min(rdi):max(rdi),min(cdi):max(cdi));
        
        figure,imshow(pictureArea);
        
        figure

        t=[];
        [L,Ne]=bwlabel(pictureArea);
        for n=1:Ne
            [r,c] = find(L==n);
            n1=pictureArea(min(r):max(r),min(c):max(c));
            n1=imresize(n1,[42,24]);
            imshow(n1)
            pause(0.2)
            x=[ ];

            totalLetters=size(imgfile,2);
            % ???????? Corr2
            
            % เปรียบเทียบกับฐานข้อมูลตัวอักษร
            for k=1:totalLetters

                y=corr2(imgfile{1,k},n1);
                x=[x y];

            end
            t=[t max(x)];
            
            % เลือกตัวอักษรที่ตรงกันมากที่สุด
            if max(x)>.35
                z=find(x==max(x));
                out=cell2mat(imgfile(2,z));

                final_output=[final_output out]
            end
        end
        final_output = [final_output '   ']
    
    end
[Sr Sc Sd] = size(pictureRGB);

% แสดงผลบนภาพต้นฉบับ
RGB = insertText(pictureRGB,[2 Sr-50],final_output,'FontSize',24);
figure, imshow(RGB);

% บันทึกผลลัพธ์
imwrite(RGB,[path,'result', file]);
file = fopen('number_Plate.txt', 'wt');
fprintf(file,'%s\n',final_output);

    fclose(file);                     
    winopen('number_Plate.txt')
