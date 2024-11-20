function ThaiCarPlate
% Main code for Car Plate Reader

clc
close all;
clear;

% รายชื่อจังหวัดทั้งหมด
province = { 'กระบี่', 'กรุงเทพมหานคร', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร', 'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท', 'ชัยภูมิ', 'ชุมพร', 'เชียงราย', 'เชียงใหม่', 'ตรัง', 'ตราด', 'ตาก', 'นครนายก', 'นครปฐม', 'นครพนม', 'นครราชสีมา', 'นครศรีธรรมราช', 'นครสวรรค์', 'นนทบุรี', 'นราธิวาส', 'น่าน', 'บึงกาฬ', 'บุรีรัมย์', 'ปทุมธานี', 'ประจวบคีรีขันธ์', 'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา', 'พะเยา', 'พังงา', 'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์', 'แพร่', 'ภูเก็ต', 'มหาสารคาม', 'มุกดาหาร', 'แม่ฮ่องสอน', 'ยโสธร', 'ยะลา', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง', 'ราชบุรี', 'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย', 'ศรีสะเกษ', 'สกลนคร', 'สงขลา', 'สตูล', 'สมุทรปราการ', 'สมุทรสงคราม', 'สมุทรสาคร', 'สระแก้ว', 'สระบุรี', 'สิงห์บุรี', 'สุโขทัย', 'สุพรรณบุรี', 'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย', 'หนองบัวลำภู', 'อ่างทอง', 'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์', 'อุทัยธานี', 'อุบลราชธานี'};

% โหลดข้อมูลตัวอักษรและตัวเลขไทย
load('imgfildataThaiLetterNumber.mat');

% เลือกไฟล์ภาพ
[file,path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s = [path,file];
picture = imread(s);
[~,cc] = size(picture);

% ปรับขนาดภาพ
picture = imresize(picture,[300 500]);
pictureRGB = picture;

% แปลงเป็นภาพขาวดำ
if size(picture,3)==3
    picture = rgb2gray(picture);
end

% แปลงเป็นภาพ binary และปรับปรุงคุณภาพ
threshold = graythresh(picture);
picture = imcomplement(imbinarize(picture,threshold));
picture = bwareaopen(picture,30);

% แสดงภาพที่ผ่านการประมวลผลเบื้องต้น
figure, imshow(picture);
title('Preprocessed Image');

% แยกพื้นที่ป้ายทะเบียน
if cc > 2000
    picture1 = bwareaopen(picture,3500);
else
    picture1 = bwareaopen(picture,4000);
end

% แยกตัวอักษรออกจากพื้นหลัง
picture2 = picture - picture1;
% picture2 = bwareaopen(picture2,200);

% หาขอบเขตตัวอักษร
[L,Ne] = bwlabel(picture2);
propied = regionprops(L,'BoundingBox');

% วาดกรอบรอบตัวอักษร
figure, imshow(picture2);
hold on
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off
title('Character Detection');

% เชื่อมตัวอักษรในแนวนอน
se = strel('rectangle',[1,200]);
ImdiPicture2 = imdilate(picture2,se);

% แยกและจดจำตัวอักษร
[Ldi,Nedi] = bwlabel(ImdiPicture2);
final_output = '';

for ndi=1:Nedi
    [rdi,cdi] = find(Ldi==ndi);
    pictureArea = picture2(min(rdi):max(rdi),min(cdi):max(cdi));
    
    [L,Ne] = bwlabel(pictureArea);
    temp_output = '';
    
    for n=1:Ne
        [r,c] = find(L==n);
        n1 = pictureArea(min(r):max(r),min(c):max(c));
        n1 = imresize(n1,[42,24]);
        
        % เปรียบเทียบกับฐานข้อมูล
        correlations = zeros(1,size(imgfile,2));
        for k=1:size(imgfile,2)
            correlations(k) = corr2(imgfile{1,k},n1);
        end
        
        % เลือกตัวอักษรที่ตรงที่สุด
        [max_corr, idx] = max(correlations);
        if max_corr > 0.35
            temp_output = [temp_output cell2mat(imgfile(2,idx))];
        end
    end
    
    final_output = [final_output temp_output '   '];
end

% แก้ไขชื่อจังหวัดและแสดงผล
final_output = correctProvinceName(final_output, province);
RGB = insertText(pictureRGB,[2 size(pictureRGB,1)-50], final_output,...
    'FontSize',24,'BoxColor','white','BoxOpacity',0.8);
figure, imshow(RGB);
title('Final Result');

% บันทึกผล
imwrite(RGB,[path,'result_',file]);
fid = fopen('number_Plate.txt', 'wt');
fprintf(fid,'%s\n',final_output);
fclose(fid);
winopen('number_Plate.txt');
end