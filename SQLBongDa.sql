CREATE TABLE San (
    MaSan NVARCHAR(10) PRIMARY KEY,
    TenSan NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255)
);
CREATE TABLE Doi (
    MaDoi NVARCHAR(10) PRIMARY KEY,
    TenDoi NVARCHAR(100) NOT NULL,
    MaSan NVARCHAR(10),
    FOREIGN KEY (MaSan) REFERENCES San(MaSan)
);
CREATE TABLE TranDau (
    MaTD INT PRIMARY KEY,
    MaSan NVARCHAR(10),
    Ngay DATE NOT NULL,
    Gio TIME NOT NULL,
    FOREIGN KEY (MaSan) REFERENCES San(MaSan)
);
CREATE TABLE CT_TranDau (
    MaTD INT,
    MaDoi NVARCHAR(10),
    SoBanThang INT CHECK (SoBanThang >= 0),
    PRIMARY KEY (MaTD, MaDoi),
    FOREIGN KEY (MaTD) REFERENCES TranDau(MaTD),
    FOREIGN KEY (MaDoi) REFERENCES Doi(MaDoi)
);
INSERT INTO San (MaSan, TenSan, DiaChi)
VALUES
('MDI', N'Mỹ Đình', N'Hà Nội – Việt Nam'),
('NAS', N'Sân vận động quốc gia', N'Viêng Chăn – Lào'),
('IMO', N'Sân I-Mobile', N'Buriram – Thái Lan'),
('MOD', N'Khu thể thao Morodok Decho', N'Russey Keo – Campuchia');
INSERT INTO Doi (MaDoi, TenDoi, MaSan)
VALUES
('VN', N'Việt Nam', 'MDI'),
('LA', N'Lào', 'NAS'),
('TL', N'Thái Lan', 'IMO'),
('CPC', 'Campuchia', 'MOD');
INSERT INTO TranDau (MaTD, MaSan, Ngay, Gio)
VALUES
('01', 'MOD', '2017-08-14', '15:00'),
('02', 'NAS', '2017-08-16', '17:00'),
('03', 'MOD', '2017-08-16', '15:00'),
('04', 'IMO', '2017-08-18', '19:00');
INSERT INTO CT_TranDau (MaTD, MaDoi, SoBanThang)
VALUES
('01', 'VN', 3),
('01', 'TL', 1),
('02', 'VN', 5),
('02', 'LA', 0),
('03', 'TL', 3),
('03', 'CPC', 3),
('04', 'TL', 2),
('04', 'LA', 0);

/*cau 1*/
select d.MaDoi, d.TenDoi, count(ct.MaDoi) as SoLanXuatHien
from Doi d
join CT_TranDau ct ON d.MaDoi = ct.MaDoi
group by d.MaDoi, d.TenDoi
/*cau 2*/
SELECT 
    T.MaTD, 
    CONCAT(CT1.MaDoi, '-', CT2.MaDoi) AS "Đội trận đấu", 
    CONCAT(CT1.SoBanThang, '-', CT2.SoBanThang) AS "Tỷ số"
FROM 
	TranDau T
JOIN     
	CT_TranDau CT1 ON T.MaTD = CT1.MaTD
JOIN 
    CT_TranDau CT2 ON CT1.MaTD = CT2.MaTD AND CT1.MaDoi < CT2.MaDoi
JOIN 
    Doi D1 ON CT1.MaDoi = D1.MaDoi
JOIN 
    Doi D2 ON CT2.MaDoi = D2.MaDoi;
/*cau 3*/
SELECT 
    CT1.MaTD AS MaTran, 
    D1.TenDoi AS Doi, 
    CASE 
        WHEN CT1.SoBanThang > CT2.SoBanThang THEN 3  -- Đội 1 thắng
        WHEN CT1.SoBanThang < CT2.SoBanThang THEN 0  -- Đội 1 thua
        ELSE 1                                       -- Hòa
    END AS Diem
FROM CT_TranDau CT1
JOIN CT_TranDau CT2 ON CT1.MaTD = CT2.MaTD AND CT1.MaDoi != CT2.MaDoi
JOIN Doi D1 ON CT1.MaDoi = D1.MaDoi
group by BY MaTran, Doi;

/*cau 4*/
SELECT D.MaDoi, D.TenDoi, SUM(
    CASE 
        WHEN CT.SoBanThang > CT2.SoBanThang THEN 3
        WHEN CT.SoBanThang = CT2.SoBanThang THEN 1
        ELSE 0
    END) AS TongDiem
FROM Doi D
JOIN CT_TranDau CT ON D.MaDoi = CT.MaDoi
JOIN CT_TranDau CT2 ON CT.MaTD = CT2.MaTD AND CT.MaDoi <> CT2.MaDoi
GROUP BY D.MaDoi, D.TenDoi;
/*cau 5*/
SELECT D.MaDoi, D.TenDoi, 
       SUM(
           CASE 
               WHEN CT1.SoBanThang > CT2.SoBanThang THEN 3
               WHEN CT1.SoBanThang = CT2.SoBanThang THEN 1
               ELSE 0
           END) AS [Tổng số điểm],
       SUM(CT1.SoBanThang - CT2.SoBanThang) AS [Hiệu Số Bàn Thắng]
FROM Doi D
JOIN CT_TranDau CT1 ON D.MaDoi = CT1.MaDoi
JOIN CT_TranDau CT2 ON CT1.MaTD = CT2.MaTD AND CT1.MaDoi <> CT2.MaDoi
GROUP BY D.MaDoi, D.TenDoi
ORDER BY [Tổng số điểm] DESC, [Hiệu Số Bàn Thắng] DESC;
/*cau 6*/
SELECT D1.MaDoi + ' - ' + D2.MaDoi AS TranChuaDa
FROM Doi D1
JOIN Doi D2 ON D1.MaDoi < D2.MaDoi
WHERE NOT EXISTS (
    SELECT 1
    FROM TranDau T
    JOIN CT_TranDau CT1 ON T.MaTD = CT1.MaTD
    JOIN CT_TranDau CT2 ON T.MaTD = CT2.MaTD AND CT1.MaDoi = D1.MaDoi AND CT2.MaDoi = D2.MaDoi
);



