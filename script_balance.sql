use Balance

EXEC sp_rename 'Registration', 'Registry'

GO

ALTER TABLE PersonalAccountInvoice 
ALTER COLUMN PersonalAccountId int NOT NULL

GO

/****** Object:  View [dbo].[ViewBalance]    Script Date: 11.03.2024 23:46:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ViewBalance] (Account, Amount)
AS
SELECT PA.Account, SUM(R.Amount) FROM Registry AS R
JOIN PersonalAccount AS PA ON R.PersonalAccountId = PA.id
GROUP BY PA.Account

GO

/****** Object:  StoredProcedure [dbo].[AddPersonalAccountMoney]    Script Date: 11.03.2024 23:48:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AddPersonalAccountMoney]
  @PersonalAccountId int,
  @Amount money,
  @Description nvarchar(200),
  @Type int
AS BEGIN
 IF  @Type = 1
 BEGIN
  INSERT INTO PersonalAccountInvoice (PersonalAccountId , SumAccount, Description ) VALUES( @PersonalAccountId, @Amount, @Description);
  INSERT INTO Registry(PersonalAccountId , Amount ) VALUES( @PersonalAccountId, -@Amount )
 END ELSE
 BEGIN
  INSERT INTO PersonalAccountPayment (PersonalAccountId , SumPayment, PurposePayment ) VALUES( @PersonalAccountId, @Amount, @Description)
  INSERT INTO Registry (PersonalAccountId , Amount ) VALUES( @PersonalAccountId, @Amount)
 END
 
-- INSERT INTO Registration (PersonalAccountId , Amount, Type ) VALUES( @PersonalAccountId, @Amount, @Type) 

END


GO
-- Добавление лицевого счета
CREATE PROCEDURE AddPersonalAccount 
(
	@Account nvarchar(50),
	@FullName nvarchar(200)
)
AS
BEGIN

	INSERT INTO PersonalAccount (Account, FullName) VALUES(@Account, @FullName)

END

GO 

CREATE PROCEDURE [dbo].[AddPersonalAccountInvoise]
  @PersonalAccount nvarchar(50),
  @Amount money,
  @Description nvarchar(200)
AS BEGIN
 
 DECLARE @PersonalAccountId int
 SET @PersonalAccountId = -1
 SELECT @PersonalAccountId = id FROM PersonalAccount WHERE Account = @PersonalAccount
 IF @PersonalAccountId = -1
 BEGIN
	INSERT INTO PersonalAccount (Account) VALUES(@PersonalAccount)	
	SELECT  @PersonalAccountId = SCOPE_IDENTITY() ; 
	--SET @PersonalAccountId = [SCOPE_IDENTITY] 
 END
 
 EXEC AddPersonalAccountMoney @PersonalAccountId, @Amount, @Description, 1

END

GO

ALTER TABLE PersonalAccount
ADD CONSTRAINT df_FullName DEFAULT '' FOR FullName

GO


ALTER TABLE PersonalAccountInvoice
DROP FK_PersonalAccountId

ALTER TABLE PersonalAccountInvoice
ADD CONSTRAINT FK_PersonalAccountId FOREIGN KEY (PersonalAccountId) REFERENCES PersonalAccount(id) ON DELETE CASCADE 

ALTER TABLE PersonalAccountPayment
DROP FK_PersonalAccountPaymentId

ALTER TABLE PersonalAccountPayment
ADD CONSTRAINT FK_PersonalAccount_PaymentId FOREIGN KEY (PersonalAccountId) REFERENCES PersonalAccount(id) ON DELETE CASCADE 

ALTER TABLE Registry
DROP FK__Registrat__Perso__76969D2E

ALTER TABLE Registry
DROP FK__Registrat__Perso__778AC167


ALTER TABLE Registry
ADD CONSTRAINT FK_PersonalAccountRegistryId FOREIGN KEY (PersonalAccountId) REFERENCES PersonalAccount(id) ON DELETE CASCADE 