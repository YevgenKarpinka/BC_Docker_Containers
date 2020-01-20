table 60001 "BC URL"
{
    DataClassification = ToBeClassified;
    LookupPageId = "BC URL List";
    Permissions = tabledata "BC Docker Container" = rd;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;

        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; URL; Text[250])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(4; Active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        BC_Dockers: Record "BC Docker Container";
    begin
        BC_Dockers.SetRange(Name, Name);
        if BC_Dockers.IsEmpty then exit;
        BC_Dockers.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}