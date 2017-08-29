function plotTimeSeries(sequence)
  xlabel('Acquisition time [s]')
  % inputname,inputParser
  hold on %# make sure subsequent plots don't overwrite the figure
  colors = ('rbgmcky'); %# define more colors here, 
                 %# or use distingushable_colors from the
                 %# file exchange, if you want to plot more than two

  %# loop through the inputs and plot
  for iArg = 1:size(sequence,2)
      var=sequence{iArg};
      plot(var(:,1),var(:,2),'color',colors(iArg));
     
  end
  grid on
end
