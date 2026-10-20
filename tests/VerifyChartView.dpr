program VerifyChartView;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes,System.Types,System.Generics.Collections,Vcl.Forms,Vcl.Controls,FlightChartsU,FlightDatabaseU;
type TChartProbe=class(TFlightCharts)
 procedure Drag(A,B:Integer;Zoom:Boolean=True);
 procedure Hover(X:Integer);
 procedure CtrlWheel;
end;
TObserver=class Index:Integer;procedure Cursor(Sender:TObject;I:Integer);end;
procedure TObserver.Cursor(Sender:TObject;I:Integer);begin Index:=I;end;
procedure TChartProbe.Drag(A,B:Integer;Zoom:Boolean);var S:TShiftState;begin S:=[];if Zoom then Include(S,ssShift);MouseDown(mbLeft,S,A,40);Include(S,ssLeft);MouseMove(S,B,40);MouseUp(mbLeft,S,B,40);end;
procedure TChartProbe.Hover(X:Integer);begin MouseMove([],X,40);end;
procedure TChartProbe.CtrlWheel;begin DoMouseWheel([ssCtrl],120,Point(0,0));end;
procedure Require(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;
var Host:TForm;C:TChartProbe;P:TTripPlot;V:TPlotPoint;O:TObserver;I:Integer;Span:Double;
begin
 Application.Initialize;Host:=TForm.CreateNew(nil);C:=TChartProbe.Create(nil);P:=TTripPlot.Create;O:=TObserver.Create;
 try
  P.Labels.Add('test');for I:=0 to 10 do begin V:=Default(TPlotPoint);V.Seconds:=100+I*10;SetLength(V.Values,1);V.Values[0]:=I;P.Points.Add(V);end;
  C.Parent:=Host;C.Width:=600;C.SetData(P);C.OnCursor:=O.Cursor;
  Require((C.ViewStart=100) and (C.ViewEnd=200),'Full view with nonzero time origin');
  C.SetView(140,160);C.Hover(60);Require(O.Index=4,'Cursor respects zoomed origin');
  C.SetView(120,160);C.Drag(300,400,False);Require((C.ViewStart<120) and (Abs(C.ViewEnd-C.ViewStart-40)<0.001),'Plain drag pans without zoom');
  C.SetView(120,160);C.Drag(500,100);
  Require((C.ViewStart>=120) and (C.ViewEnd<=160) and (C.ViewEnd>C.ViewStart),'Reverse mouse selection');
  Span:=C.ViewEnd-C.ViewStart;C.Pan(1);Require(Abs(C.ViewEnd-200)<0.001,'Pan to end');
  C.CtrlWheel;Require(C.ViewEnd-C.ViewStart<Span,'Ctrl wheel zoom');
  C.ResetView;Require((C.ViewStart=100) and (C.ViewEnd=200),'Reset full view');
 finally C.Free;Host.Free;P.Free;O.Free;end;
 Writeln('PASS: chart viewport, nonzero origin, cursor mapping, reverse drag zoom, panning, Ctrl+wheel and reset.');
end.
