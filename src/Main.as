package  
{
	import cepa.utils.ToolTip;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flashandmath.as3.tools.SimpleGraph;
	import fl.controls.RadioButton;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import fl.core.UIComponent;
	import fl.controls.RadioButtonGroup;
	import fl.controls.RadioButton;
	import fl.controls.Label; 
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.filters.ColorMatrixFilter;
	
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	
	import pipwerks.SCORM;
	/**
	 * ...
	 * @author Brunno
	 */
	public class Main extends MovieClip
	{
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		
		private var numEquations:Number = 5;
		private var valores:Array = new Array();
		private var powVar:Number = rand(1,2);//negativo ou positivo os parametros
		private var randomA:Array = new Array();//escolhe os valores
		private var randomB:Array = new Array();//escolhe os valores
		private var randomC:Array = new Array();//escolhe os valores
		private var randomD:Array = new Array();//escolhe os valores
		private var randomTrue:Number;//escolhe a equação verdadeira
		private var equation:Array = new Array(numEquations);
		private var labelEq:Array = new Array(numEquations);
		private var labelText:Array = new Array();
		private var offset:Number = 10;
		private var aLabel:Label = new Label();// Certo ou Errado
		//
		//RadioButton Vars
		private var rbGrp:RadioButtonGroup = new RadioButtonGroup("respGroup");
		private var respUser:String = "";
		private var indiceUser:String;
		private var newFormat:TextFormat = new TextFormat();
		private var newFormat2:TextFormat = new TextFormat();
		private var correct:TextFormat = new TextFormat();
		private var wrong:TextFormat = new TextFormat();
		private var correct2:TextFormat = new TextFormat();
		private var wrong2:TextFormat = new TextFormat();
		private var correto:TextFormat = new TextFormat();
		private var wronge:TextFormat = new TextFormat();
		
		//Buttons Vars
		private var btCheck:SimpleButton;
		private var btNew:SimpleButton;
		
		//Graph Vars
		private var Graph:SimpleGraph;
		private var xRange:Array = [-5, 5];
		private var yRange:Array = [-5, 5];
		private var GRAPH_WIDTH = 420;
		private var GRAPH_HEIGHT = 380;
		
		//SCORM VARIABLES
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormTimeTry:String;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		private var lastTimes:* = 0;//quantas vezes ele ja fez
		private var lastScore:* = 0;//pontuação anterior
		private var maxTimes:int = 5;
		private var valores2:Array = new Array();
		
		private var orientacoesScreen:InstScreen;
		private var creditosScreen:AboutScreen;
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		private const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		public function Main() 
		{
			init();
		}
		
		/**
		 * @private
		 * Inicialização (CRIAÇÃO DE OBJETOS) independente do palco (stage).
		 */
		private function init () : void
		{
			aLabel.x = 365; 
			aLabel.y = 225; 
			aLabel.width = 300; 
			aLabel.height = 22;
			
			newFormat.bold = false;
			newFormat.font = "Verdana";
			newFormat.size = 14;
			newFormat.color = 0x000000;
			newFormat.tabStops = [50, 150];
			
			newFormat2.bold = false;
			newFormat2.font = "Verdana";
			newFormat2.size = 12;
			newFormat2.color = 0x000000;
			newFormat2.tabStops = [50, 150];
			
			correct.bold = true;
			correct.font = "Verdana";
			correct.size = 14;
			correct.color = 0x006600;
			
			wrong.bold = true;
			wrong.font = "Verdana";
			wrong.size = 14;
			wrong.color = 0xFF0000;
			
			correct2.bold = true;
			correct2.font = "Verdana";
			correct2.size = 12;
			correct2.color = 0x006600;
			
			wrong2.bold = true;
			wrong2.font = "Verdana";
			wrong2.size = 12;
			wrong2.color = 0xFF0000;

			correto.bold = true;
			correto.font = "Verdana";
			correto.size = 14;
			correto.color = 0x006600;
			

			wronge.bold = true;
			wronge.font = "Verdana";
			wronge.size = 14;
			wronge.color = 0xFF0000;
			
			//Valores
			valores[0] = -2;
			valores[1] = -1;
			valores[2] = 1;
			valores[3] = 2;
			
			valores2[0] = -2;
			valores2[1] = -1;
			valores2[2] = 0;
			valores2[3] = 1;
			valores2[4] = 2;
			//Fim valores
			
			if (stage) stageDependentInit();
			else addEventListener(Event.ADDED_TO_STAGE, stageDependentInit);
		}
		
		/**
		 * @private
		 * Inicialização (CRIAÇÃO DE OBJETOS) dependente do palco (stage).
		 */
		private function stageDependentInit (event:Event = null) : void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageDependentInit);
			
			this.scrollRect = new Rectangle(0, 0, 700, 400);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			initContextMenu();
			
			btCheck = new BotaoTerminei();
			btCheck.x = 450 + btCheck.width / 2;
			btCheck.y = 230;
			
			btNew = new BotaoReiniciar();
			btNew.x = btCheck.x + btCheck.width / 2 + 15 + btNew.width / 2;
			btNew.y = 230;
			
			addChild(btCheck);
			addChild(btNew);
			
			geraEq();
			corrEq();
			
			pontaY.x = Graph.x + GRAPH_WIDTH / 2 + 0.5;
			pontaY.y = Graph.y;
			
			pontaX.x = Graph.x + GRAPH_WIDTH;
			pontaX.y = Graph.y + GRAPH_HEIGHT / 2 + 0.5;
			
			addListeners();
			
			initLMSConnection();
			
			iniciaTutorial();
		}
		
		private function addListeners():void 
		{
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, btNewa);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			
			btCheck.addEventListener(MouseEvent.CLICK, btChecka);
			btNew.addEventListener(MouseEvent.CLICK, btNewa);
			
			createToolTips();
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			
			//var finalizaTT:ToolTip = new ToolTip(btCheck, "Finaliza atividade", 12, 0.8, 200, 0.6, 0.1);
			//var newTT:ToolTip = new ToolTip(btNew, "Reiniciar", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			
			//addChild(finalizaTT);
			//addChild(newTT);
		}
		
		private function btChecka(event:MouseEvent):void {
			if(respUser != ""){
				if(respUser == labelEq[randomTrue].value){
					//labelEq[randomTrue].setStyle("textFormat", correct);
					labelText[randomTrue].setTextFormat(correct);
					
					btCheck.mouseEnabled = false;
					btCheck.alpha = 0.5;
					btCheck.filters = [GRAYSCALE_FILTER];
					
					btNew.mouseEnabled = true;
					btNew.alpha = 1;
					btNew.filters = [];
					
					botoes.resetButton.mouseEnabled = true;
					botoes.resetButton.alpha = 1;
					botoes.resetButton.filters = [];
					
					//addChild(aLabel);
					aLabel.setStyle("textFormat", correto);
					aLabel.text = "Resposta correta!";
					//SCORM -----------
					if (!completed)
					{
						//lastTimes++;
						//lastScore += 20;
						//if (lastTimes == maxTimes) {
							lastScore = 100;
							completed = true;
							//aviso.visible = true;
						//}
						save2LMS();
					}
					//-----------------
				}
				if(respUser != labelEq[randomTrue].value){
					//labelEq[Number(indiceUser)].setStyle("textFormat", wrong);
					labelText[indiceUser].setTextFormat(wrong);
					labelText[randomTrue].setTextFormat(correct);
					btCheck.mouseEnabled = false;
					btCheck.alpha = 0.5;
					btCheck.filters = [GRAYSCALE_FILTER];
					
					btNew.mouseEnabled = true;
					btNew.alpha = 1;
					btNew.filters = [];
					
					botoes.resetButton.mouseEnabled = true;
					botoes.resetButton.alpha = 1;
					botoes.resetButton.filters = [];
					//addChild(aLabel);
					aLabel.setStyle("textFormat", wronge);
					aLabel.text = "Resposta incorreta!";
					//SCORM -----------
					if (!completed)
					{
						//lastTimes++;
						//if (lastTimes == maxTimes) {
							lastScore = 0;
							completed = true;
							//aviso.visible = true;
						//}
						save2LMS();
					}
					//-----------------
				}
			}else
			{	
				
			}
		}
		
		private function btNewa(event:MouseEvent):void {
			//removeChild(aLabel);
			respUser = "";
			for (var i:uint = 1; i <= numEquations; i++) {
				removeChild(labelEq[i]);
				removeChild(labelText[i]);
			}
			geraEq();
			corrEq();
			setChildIndex(balao, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		//f(x) = a + b * ln[c * (x-d)]
		//Função que gera equações
		private function geraEq() {
			for (var i:uint = 1; i <= numEquations; i++) {
				randomA[i] = valores2[rand(0, 4)];
				randomB[i] = valores[rand(0, 3)];
				randomC[i] = valores[rand(0, 3)];
				randomD[i] = valores2[rand(0, 4)];
				equation[i]= randomA[i] + "+(" + randomB[i] + ")*ln(" + randomC[i] + "*(x - " + randomD[i] + "))";
			}
			if (!comparaEq()) {
				for (var j:uint = 1; j <= numEquations; j++) {
				labelEq[j] = new RadioButton();
				labelEq[j].x = 450;
				labelEq[j].y = 25 + 30*j;
				labelEq[j].label = "";
				labelEq[j].value = "y = "+ String(equation[j]).replace("*","");
				labelEq[j].name = j;
				labelEq[j].group = rbGrp;
				labelEq[j].width = 200;
				labelEq[j].setStyle("textFormat", newFormat);
				addChild(labelEq[j]);
				labelText[j] = new TextField();
				labelText[j].x = 30 + 450;
				labelText[j].y = 25 + 30*j;
				labelText[j].text = "y = "+ String(equation[j]).replace("*","").replace("- -","+ ");
				labelText[j].setTextFormat(newFormat);
				labelText[j].autoSize = "left";
				labelText[j].selectable = false;
				addChild(labelText[j]);
				}
				rbGrp.addEventListener(MouseEvent.CLICK, clickHandler);
				
				btCheck.mouseEnabled = false;
				btCheck.alpha = 0.5;
				btCheck.filters = [GRAYSCALE_FILTER];
				
				btNew.mouseEnabled = false;
				btNew.alpha = 0.5;
				btNew.filters = [GRAYSCALE_FILTER];
				
				botoes.resetButton.mouseEnabled = false;
				botoes.resetButton.filters = [GRAYSCALE_FILTER];
				botoes.resetButton.alpha = 0.5;
			}
		}

		private function clickHandler(event:MouseEvent):void { 
			respUser = event.target.selection.value;
			indiceUser = event.target.selection.name;
			
			btCheck.mouseEnabled = true;
			btCheck.alpha = 1;
			btCheck.filters = [];
		} 

		//Função que verifica se existem eq iguais
		private function comparaEq():Boolean {
			for (var i:uint = 1; i <= numEquations; i++) {
				for (var j:uint = i+1; j <= numEquations; j++) {
					if ((randomB[i] == randomB[j] && randomC[i] == randomC[j])) {
						geraEq();
						return true;
					}
				}
			}
			return false;
		}

		//Função que escolhe equação correta e gera o gráfico
		private function corrEq():void {
			randomTrue = rand(1,numEquations);
			equation[randomTrue] = randomA[randomTrue] + "+" + randomB[randomTrue] + "*ln(" + randomC[randomTrue] + "*(x-" + randomD[randomTrue] + "))";
			// Gráfico
			if (Graph != null) removeChild(Graph);
			
			Graph = new SimpleGraph(GRAPH_WIDTH, GRAPH_HEIGHT);
			
			Graph.x = offset;
			Graph.y = offset;
			Graph.board.setVarsRanges(xRange[0], xRange[1], yRange[0], yRange[1]);
			Graph.board.drawAxes();
			Graph.board.changeBorderColorAndThick(0xFFFFFF, 0);
			Graph.board.changeBackAlpha(0);
			//Graph.board.setCrossSizeAndThick(10, 10);
			//Graph.board.setTicks(2, 2, 10, 10);
			Graph.board.drawTicks();
			//Graph.board.drawGrid();
			Graph.board.addLabels();
			Graph.board.disableCoordsDisp();
			Graph.graphRectangular(equation[randomTrue], "x", 1, 2, 0xCC0000);
			addChild(Graph);
			
			setChildIndex(pontaX, numChildren - 1);
			setChildIndex(pontaY, numChildren - 1);
		}

		//Função que limpa alternativas

	

		//Função que calcula inteiros aleatórios entre 2 numeros
		private function rand(min:Number, max:Number):Number {
			return Math.round(Math.random() * max + 1 - min + min - 0.5);
		}
		
		
		//Menu de contexto
		private function initContextMenu() : void
		{
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
            var defaultItems:ContextMenuBuiltInItems = menu.builtInItems;
            defaultItems.print = true;
			
			var item:ContextMenuItem = new ContextMenuItem("Sobre...");
            menu.customItems.push(item);
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (e:Event) { setChildIndex(creditosScreen, numChildren -1); setChildIndex(bordaAtividade, numChildren -1); creditosScreen.openScreen() } );
			contextMenu = menu;
		}
		
		
		//Tutorial
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var pointsTuto2:Array;
		private var tutoBaloonPos:Array;
		private var tutoBaloonPos2:Array;
		private var tutoPos:int;
		private var tutoPhaseFinal:Boolean;
		private var tutoSequence:Array = ["Este é o gráfico de uma função logarítmica, escolhida aleatoriamente.",
										  "Uma dessas alternativas contém a expressão da função cujo gráfico aparece ao lado. Identifique-a e, em seguida, pressione \"terminei\"."];
										  
		private var tutoSequence2:Array = ["A resposta correta foi destacada em verde."];
										  
		private var ptAltCerto:Point = new Point();
		
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			tutoPhaseFinal = false;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(Graph.x + GRAPH_WIDTH / 2, Graph.y + GRAPH_HEIGHT / 2),
								new Point(455, 127)];
								
				tutoBaloonPos = [[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER]];
								
				pointsTuto2 = 	[ptAltCerto];
								
				tutoBaloonPos2 = 	[[CaixaTexto.RIGHT, CaixaTexto.CENTER]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			btCheck.removeEventListener(MouseEvent.CLICK, iniciaTutorialSegundaFase);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
			setChildIndex(balao, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function closeBalao(e:Event):void 
		{
			ptAltCerto.x = labelEq[randomTrue].x;
			ptAltCerto.y = labelEq[randomTrue].y + labelEq[randomTrue].height / 2;
			
			if (tutoPhaseFinal) {
				tutoPos++;
				if (tutoPos >= tutoSequence2.length) {
					balao.removeEventListener(Event.CLOSE, closeBalao);
					balao.visible = false;
					btCheck.removeEventListener(MouseEvent.CLICK, iniciaTutorialSegundaFase);
					tutoPhaseFinal = false;
				}else {
					btCheck.removeEventListener(MouseEvent.CLICK, iniciaTutorialSegundaFase);
					balao.setText(tutoSequence2[tutoPos], tutoBaloonPos2[tutoPos][0], tutoBaloonPos2[tutoPos][1]);
					balao.setPosition(pointsTuto2[tutoPos].x, pointsTuto2[tutoPos].y);
					setChildIndex(balao, numChildren - 1);
					setChildIndex(bordaAtividade, numChildren - 1);
				}
			}else{
				tutoPos++;
				if (tutoPos >= tutoSequence.length) {
					balao.removeEventListener(Event.CLOSE, closeBalao);
					balao.visible = false;
					btCheck.addEventListener(MouseEvent.CLICK, iniciaTutorialSegundaFase);
					tutoPhaseFinal = true;
				}else {
					balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
					balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
					setChildIndex(balao, numChildren - 1);
					setChildIndex(bordaAtividade, numChildren - 1);
				}
			}
		}
		
		private function iniciaTutorialSegundaFase(e:MouseEvent):void 
		{
			if (respUser == "") return;
			if (tutoPhaseFinal) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				tutoPos = 0;
				balao.setText(tutoSequence2[tutoPos], tutoBaloonPos2[tutoPos][0], tutoBaloonPos2[tutoPos][1]);
				balao.setPosition(pointsTuto2[tutoPos].x, pointsTuto2[tutoPos].y);
				balao.addEventListener(Event.CLOSE, closeBalao);
				setChildIndex(balao, numChildren - 1);
				setChildIndex(bordaAtividade, numChildren - 1);
			}
		}
		
		
		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			
			completed = false;
			connected = false;
			
			scorm = new SCORM();
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
 
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");				
			 
				switch(status)
				{
					// Primeiro acesso à AI// Continuando a AI...
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						scormTimeTry = "times=0,points=0";
						score = 0;
						break;
					
					case "incomplete":
						completed = false;
						scormTimeTry = scorm.get("cmi.location");
						score = 0;
						break;
						
					// A AI já foi completada.
					case "completed"://Apartir desse momento os pontos nao serão mais acumulados
						completed = true;
						scormTimeTry = scorm.get("cmi.location");//Deve contar a quantidade de funções que ele fez e tambem média que ele tinha
						score = 0;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				//Tratamento do scormTimeTry--------------------------------------------------------------------
				if (!completed)//Somente se a atividade nao estiver completa
				{
					var lista:Array = scormTimeTry.split(",");
					for(var i = 0; i < lista.length; i++)
					{
						if(i == 0)
						{
							lastTimes = lista[i].substr(lista[i].search("=")+1);
						}else if(i == 1)
						{
							lastScore = lista[i].substr(lista[i].search("=")+1);
						}
					}
				}
				//----------------------------------------------------------------------------------------------
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				//setMessage("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			//reset();
			
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function save2LMS ()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", (lastScore).toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				scormTimeTry = "times=" + lastTimes + ",points=" + lastScore;
				success = scorm.set("cmi.location", scormTimeTry);

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			if (connected)
			{
				var success:Boolean = scorm.set("cmi.session_time", Math.round(pingTimer.currentCount * PING_INTERVAL / 1000).toString());
				
				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	}

}