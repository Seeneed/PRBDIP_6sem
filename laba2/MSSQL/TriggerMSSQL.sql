CREATE OR ALTER TRIGGER order_audit_trg ON Orders
AFTER UPDATE AS BEGIN
    PRINT 'Данные заказа обновлены';
END;

DROP TRIGGER order_audit_trg;