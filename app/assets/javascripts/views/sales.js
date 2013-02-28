var sales = {
  chart: null,
  chart_data: null,
  setup: function(){
    sales.chart_data = {
      categories: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      series: [
        {name: "Image 1", data: [100, 110, 120, 100, 135, 140]},
        {name: "Image 2", data: [100, 120, 130, 110, 140, 150]},
        {name: "Image 3", data: [110, 130, 150, 135, 160, 170]},
        {name: "Image 4", data: [120, 140, 150, 160, 170, 180]},
        {name: "Image 5", data: [130, 150, 140, 145, 160, 165]}
      ]
    };

    sales.chart = new Highcharts.Chart({
      chart: {
        renderTo: 'daily-sales-chart-container',
        defaultSeriesType: 'line',
        marginRight: 130,
        marginBottom: 25
      },
      credits: {
        enabled: false
      },
      title: {
        text: 'Total Daily Sales',
        x: -20 //center
      },
      xAxis: {
        categories: sales.chart_data.categories
      },
      yAxis: {
        title: {
           text: 'Gross ($)'
        },
        plotLines: [{
          value: 0,
          width: 1,
          color: '#808080'
        }]
      },
      tooltip: {
        formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>' + this.x +': ' + '$' + this.y;
        }
      },
      plotOptions: {
        line: {
          marker: {
            radius: 4
          }
        }
      },
      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'top',
        x: -10,
        y: 100,
        borderWidth: 0
      },
      series: sales.chart_data.series
    });
  }
};
