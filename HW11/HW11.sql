create database MyMTGCollection
go
use MyMTGCollection

CREATE TABLE [Set] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(7)  NOT NULL ,
    CONSTRAINT [PK_Set] PRIMARY KEY CLUSTERED (
        [ID] ASC
    ),
    CONSTRAINT [UK_Set_Name] UNIQUE (
        [Name]
    ),
    CONSTRAINT [UK_Set_Code] UNIQUE (
        [Code]
    )
)

CREATE TABLE [Box] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(7)  NOT NULL ,
    CONSTRAINT [PK_Box] PRIMARY KEY CLUSTERED (
        [ID] ASC
    ),
    CONSTRAINT [UK_Box_Name] UNIQUE (
        [Name]
    )
)

CREATE TABLE [Card_type] (
    [ID] int  NOT NULL ,
    [Name_EN] nvarchar(250)  NOT NULL ,
    [Name_RU] nvarchar(250)  NOT NULL ,
    CONSTRAINT [PK_Card_type] PRIMARY KEY CLUSTERED (
        [ID] ASC
    ),
    CONSTRAINT [UK_Card_type_Name_EN] UNIQUE (
        [Name_EN]
    ),
    CONSTRAINT [UK_Card_type_Name_RU] UNIQUE (
        [Name_RU]
    )
)

CREATE TABLE [Rarity] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(10)  NOT NULL ,
    [Code] nvarchar(7)  NOT NULL ,
    CONSTRAINT [PK_Rarity] PRIMARY KEY CLUSTERED (
        [ID] ASC
    ),
    CONSTRAINT [UK_Rarity_Name] UNIQUE (
        [Name]
    ),
    CONSTRAINT [UK_Rarity_Code] UNIQUE (
        [Code]
    )
)

CREATE TABLE [Card] (
    [ID] int  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(7)  NOT NULL ,
    [Set_ID] int  NOT NULL ,
    [Card_type_ID] int  NOT NULL ,
    [Rarity_ID] int  NOT NULL ,
    CONSTRAINT [PK_Card] PRIMARY KEY CLUSTERED (
        [ID] ASC
    )
)

CREATE TABLE [Collection] (
    [Card_ID] int  NOT NULL ,
    [Quantity] int  NOT NULL ,
    [Box_ID] int  NOT NULL 
)

ALTER TABLE [Card] WITH CHECK ADD CONSTRAINT [FK_Card_Set_ID] FOREIGN KEY([Set_ID])
REFERENCES [Set] ([ID])

ALTER TABLE [Card] CHECK CONSTRAINT [FK_Card_Set_ID]

ALTER TABLE [Card] WITH CHECK ADD CONSTRAINT [FK_Card_Card_type_ID] FOREIGN KEY([Card_type_ID])
REFERENCES [Card_type] ([ID])

ALTER TABLE [Card] CHECK CONSTRAINT [FK_Card_Card_type_ID]

ALTER TABLE [Card] WITH CHECK ADD CONSTRAINT [FK_Card_Rarity_ID] FOREIGN KEY([Rarity_ID])
REFERENCES [Rarity] ([ID])

ALTER TABLE [Card] CHECK CONSTRAINT [FK_Card_Rarity_ID]

ALTER TABLE [Collection] WITH CHECK ADD CONSTRAINT [FK_Collection_Card_ID] FOREIGN KEY([Card_ID])
REFERENCES [Card] ([ID])

ALTER TABLE [Collection] CHECK CONSTRAINT [FK_Collection_Card_ID]

ALTER TABLE [Collection] WITH CHECK ADD CONSTRAINT [FK_Collection_Box_ID] FOREIGN KEY([Box_ID])
REFERENCES [Box] ([ID])

ALTER TABLE [Collection] CHECK CONSTRAINT [FK_Collection_Box_ID]

