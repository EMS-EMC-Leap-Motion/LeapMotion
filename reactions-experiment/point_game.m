// The entrypoint of the game - defined to be run from the REPL
function point_game(name,t_end,delay_in,gain,noise_level)
close all
addpath('Support files')

%name='test';
%t_end=90;%
samplingfreq=100;
delay=round(delay_in*samplingfreq);%
%noise_level=0.1;
%gain=1;

my_fig = figure('color','k',...
    'MenuBar','none',...
    'ToolBar','none',...
    'Name','Mirror game',...
    'WindowState','Fullscreen',...
    'NumberTitle','off','KeyPressFcn',@ESCKey_Down);

AxesH = axes('Parent', my_fig, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'Visible', 'off', ...
    'XLim', [-0.52, 0.52], ...
    'YLim', [-0.1, 1.1], ...
    'NextPlot', 'add');

%clf

set(gca,'position',[0 0 1 1],...%[0.05 0 0.9 1]
    'XtickLabel',[],...
    'YtickLabel',[],'Ylim',[-0.1 1.1],'Xlim',[-0.52 0.52],...
    'color','k','SortMethod','childorder')

set(my_fig,'color','k','MenuBar','none','ToolBar','none','KeyPressFcn',@ESCKey_Down);%,'Renderer','painters')

%cla
axis off
text(0,0.6,{'Please use your finger to'...
    'move the orange dot towards the center of the screen.',...
    '',...
    'To start click or press any key.'},...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle',...
    'Fontunits','normalized',...
    'color','w','Fontsize',0.07);

wait_for_key(my_fig)
countdown(3)

sky=patch([-0.52 0.52 0.52 -0.52],[0.45 0.45 1.1 1.1],'k','facecolor',[0.5 0.75 0.93],'edgecolor','none');
hold on
earth=patch([-0.52 0.52 0.52 -0.52],[-0.1 -0.1 0.45 0.45],'k','facecolor',[0.47 0.67 0.19],'edgecolor','none');
curunits = get(gca, 'Units');
set(gca, 'Units', 'Points');
cursize = get(gca, 'Position');
set(gca, 'Units', curunits);
s_sz=(cursize(3)-cursize(1));
C1_img=plot(0,0.5,'k','marker','o','Markerfacecolor','k','MarkerSize',0.5*s_sz);
hold on

C2_img=plot(0,0.5,'color',0.85*ones(1,3),'marker','o','Markerfacecolor',0.85*ones(1,3),'MarkerSize',0.4*s_sz);
C3_img=plot(0,0.5,'k','marker','o','Markerfacecolor','k','MarkerSize',0.3*s_sz);
C4_img=plot(0,0.5,'color',0.85*ones(1,3),'marker','o','Markerfacecolor',0.85*ones(1,3),'MarkerSize',0.2*s_sz);
C5_img=plot(0,0.5,'k','marker','o','Markerfacecolor','k','MarkerSize',0.1*s_sz);

pointred=plot(getHandPositionLeap(0,0,1),0.15,'color',[1 0.35 0],'marker','o','MarkerFaceColor',[1 0.35 0],'MarkerSize',0.1*s_sz);

set(gca,'Ydir','Normal')

axis off

set(gcf, 'Pointer', 'custom', 'PointerShapeCData', NaN(16,16))

pause(0.75)

%%%%%%%%%%

data_out=zeros(t_end*1.5*samplingfreq,5);
noise_in=[smooth(rand(t_end*1.5*samplingfreq,1)-0.5,50), ...
          smooth(rand(t_end*1.5*samplingfreq,1)-0.5,50)];

tt=1;

t_start=tic;

pos_hp_x=0;
pos_hp_y=0;
sec=0;
while (sec < t_end)
    t_frame=tic;
    sec=toc(t_start);
    
    if tt<5*samplingfreq
        [pos_hp_x,pos_hp_y] = getHandPositionLeap(pos_hp_x,pos_hp_y,gain);
        disp_pos_hp_x=pos_hp_x;
        disp_pos_hp_y=pos_hp_y; 
    elseif tt>=5*samplingfreq && tt<10*samplingfreq
        [pos_hp_x,pos_hp_y] = getHandPositionLeap(pos_hp_x,pos_hp_y,gain);
        disp_pos_hp_x=pos_hp_x+noise_level*noise_in(tt,1);
        disp_pos_hp_y=pos_hp_y+noise_level*noise_in(tt,2);
    elseif tt>=10*samplingfreq
        [pos_hp_x,pos_hp_y] = getHandPositionLeap(disp_pos_hp_x,disp_pos_hp_y,gain);
        disp_pos_hp_x=data_out(tt-delay-1,2)+noise_level*noise_in(tt,1);
        disp_pos_hp_y=data_out(tt-delay-1,3)+noise_level*noise_in(tt,2);
    end
    
    data_out(tt,:)=[sec, pos_hp_x, pos_hp_y, disp_pos_hp_x, disp_pos_hp_y];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    set(pointred,'XData',disp_pos_hp_x,'YData',disp_pos_hp_y);
    
    
    tt_frame=toc(t_frame);
    if tt_frame < 0.01
        pause(0.01-tt_frame)
    end

    tt=tt+1;
end

cla
axis off
text(0,0.5,{'Thank You!'},...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle',...
    'Fontunits','normalized',...
    'color','w','Fontsize',0.2);

pause(0.75)

set(gcf, 'Pointer', 'arrow')

data_out=data_out(1:tt-1,:);

save_name=strcat(name, '.csv');
csvwrite(save_name,data_out);
end

function countdown(n)
cla
text_above = text(0,0.75,'Game starts in:', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle',...
    'color','w',...
    'Fontunits','normalized',...
    'FontSize',0.2);

text_count = text(0,0.35,num2str(n), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle',...
    'color','w',...
    'Fontunits','normalized',...
    'FontSize',0.2);

for i=(n-1):-1:1
    pause(1)
    set(text_count,'String',num2str(i))
    drawnow
end
end

function wait_for_key(FigH)
warning ('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFig = get(FigH,'JavaFrame');
jFig.requestFocus
w=waitforbuttonpress;
if w==1 || w==0
    cla
    return
end
end