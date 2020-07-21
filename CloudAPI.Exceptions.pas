﻿unit CloudAPI.Exceptions;

interface

uses
  CloudAPI.Parameter,
  System.SysUtils;

type
  ECloudApiException = class(Exception)
  private
    FCodeInt: Integer;
    FCodeStr: string;
    FText: string;
    FRaisedAt: TDateTime;
  protected
    procedure BuildMsg; virtual;
  public
    constructor Create(const ACode, AText: string); overload;
    constructor Create(const ACode: Integer; const AText: string); overload;
  published
    property CodeInt: Integer read FCodeInt write FCodeInt;
    property CodeStr: string read FCodeStr write FCodeStr;
    property Text: string read FText write FText;
    property RaisedAt: TDateTime read FRaisedAt write FRaisedAt;
  end;

  ECloudApiRequairedParameterException = class(ECloudApiException)
  private
    FParameter: TcaParameter;
    FMethod: string;
  protected
    procedure BuildMsg; override;
  public
    constructor Create(const AMethod: string; AParameter: TcaParameter);
  end;

implementation

uses
  CloudAPI.Core.Constants;
{ ECloudApiRequairedParameterException }

procedure ECloudApiRequairedParameterException.BuildMsg;
begin
  inherited BuildMsg;
  Message := Message //
    .Replace('{Parameter.Name}', FParameter.Name) //
    .Replace('{Parameter.Value}', FParameter.ValueAsString) //
    .Replace('{Method}', FMethod) //
    ;
end;

constructor ECloudApiRequairedParameterException.Create(const AMethod: string; AParameter: TcaParameter);
var
  LMsg: string;
begin
  FParameter := AParameter;
  FMethod := AMethod;
  inherited Create('CloudAPI', TcaConstException.PARAMETER_REQIRED);
end;

{ ECloudApiException }

constructor ECloudApiException.Create(const ACode, AText: string);
begin
  FCodeStr := ACode;
  TryStrToInt(ACode, FCodeInt);
  FText := AText;
  FRaisedAt := Now;
  inherited Create(Message);
  BuildMsg;
end;

procedure ECloudApiException.BuildMsg;
var
  LRaisedAtStr: string;
begin
  LRaisedAtStr := FormatDateTime(TcaConstException.RAISED_AT_FORMAT, FRaisedAt, TFormatSettings.Invariant);
  Message := TcaConstException.EXCEPTION_MSG_FORMAT //
    .Replace('{Code}', CodeStr) //
    .Replace('{RaisedAt}', LRaisedAtStr) //
    .Replace('{Message}', Text) //
end;

constructor ECloudApiException.Create(const ACode: Integer; const AText: string);
begin
  self.Create(ACode.ToString, AText);
end;

end.
