function corrected_output = correctProvinceName(detected_text, province_list)
% แก้ไขชื่อจังหวัดโดยใช้ Levenshtein distance
    
    parts = strsplit(strtrim(detected_text));
    if length(parts) < 2
        corrected_output = detected_text;
        return;
    end
    
    % แยกส่วนตัวเลขทะเบียนและชื่อจังหวัด
    plate_number = parts{1};
    if length(parts) >= 2
        province_part = strjoin(parts(2:end));
    else
        province_part = '';
    end
    
    % หาจังหวัดที่ใกล้เคียงที่สุด
    min_distance = inf;
    best_match = province_part;
    
    for i = 1:length(province_list)
        distance = levenshteinDistance(province_part, province_list{i});
        if distance < min_distance
            min_distance = distance;
            best_match = province_list{i};
        end
    end
    
    % ปรับปรุงผลลัพธ์เฉพาะเมื่อความเหมือนมากพอ
    if min_distance <= length(province_part) * 0.4
        corrected_output = [plate_number ' ' best_match];
    else
        corrected_output = detected_text;
    end
end

function distance = levenshteinDistance(str1, str2)
% คำนวณระยะห่าง Levenshtein ระหว่างสองสตริง
    
    s1 = char(str1);
    s2 = char(str2);
    
    m = length(s1);
    n = length(s2);
    d = zeros(m+1, n+1);
    
    for i = 1:m+1
        d(i,1) = i-1;
    end
    for j = 1:n+1
        d(1,j) = j-1;
    end
    
    for j = 2:n+1
        for i = 2:m+1
            if s1(i-1) == s2(j-1)
                substitutionCost = 0;
            else
                substitutionCost = 1;
            end
            d(i,j) = min([d(i-1,j) + 1,...     % deletion
                         d(i,j-1) + 1,...     % insertion
                         d(i-1,j-1) + substitutionCost]); % substitution
        end
    end
    
    distance = d(m+1,n+1);
end
