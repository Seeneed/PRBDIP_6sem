create table Personal_Files (
    ID NUMBER PRIMARY KEY,
    FOTO BLOB,
    DOC BFILE
) TABLESPACE lob_tbs
LOB (FOTO) STORE AS (TABLESPACE lob_tbs);


INSERT INTO Personal_Files (ID, FOTO, DOC)
VALUES (
    1, 
    EMPTY_BLOB(), 
    BFILENAME('LOB_DIR', 'Mamonko_Denis_CV_English.pdf')
);
COMMIT;

INSERT INTO Personal_Files (ID, FOTO, DOC)
VALUES (
    2, 
    EMPTY_BLOB(), 
    BFILENAME('LOB_DIR', 'Mamonko_Denis_CV_Russian.pdf')
);
COMMIT;



DECLARE
    v_bfile     BFILE;
    v_blob      BLOB;
    v_amount    INTEGER;
BEGIN
    v_bfile := BFILENAME('LOB_DIR', 'UML-диаграмма.png');

    SELECT FOTO INTO v_blob 
    FROM Personal_Files 
    WHERE ID = 1
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    
    v_amount := DBMS_LOB.GETLENGTH(v_bfile);

    DBMS_LOB.LOADFROMFILE(
        dest_lob => v_blob,
        src_lob  => v_bfile,
        amount   => v_amount
    );

    DBMS_LOB.FILECLOSE(v_bfile);
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Успешно! Ресурс загружен');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
        IF DBMS_LOB.FILEISOPEN(v_bfile) = 1 THEN
            DBMS_LOB.FILECLOSE(v_bfile);
        END IF;
        ROLLBACK;
END;
/


DECLARE
    v_bfile     BFILE;
    v_blob      BLOB;
    v_amount    INTEGER;
BEGIN
    v_bfile := BFILENAME('LOB_DIR', 'UML-диаграмма.png');

    SELECT FOTO INTO v_blob 
    FROM Personal_Files 
    WHERE ID = 2
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    
    v_amount := DBMS_LOB.GETLENGTH(v_bfile);

    DBMS_LOB.LOADFROMFILE(
        dest_lob => v_blob,
        src_lob  => v_bfile,
        amount   => v_amount
    );

    DBMS_LOB.FILECLOSE(v_bfile);
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Успешно! Ресурс загружен');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
        IF DBMS_LOB.FILEISOPEN(v_bfile) = 1 THEN
            DBMS_LOB.FILECLOSE(v_bfile);
        END IF;
        ROLLBACK;
END;
/

SELECT 
    ID, 
    DBMS_LOB.GETLENGTH(FOTO) AS FOTO_SIZE_BYTES,
    DBMS_LOB.GETLENGTH(DOC)  AS DOC_SIZE_BYTES, 
    DOC                                         
FROM PERSONAL_FILES;

select * from PERSONAL_FILES;

DROP TABLE Personal_Files;