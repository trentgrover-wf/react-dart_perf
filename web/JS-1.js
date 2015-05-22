
var BoxesView = React.createClass({

    render: function() {
        var N = 250;
        var boxes = [];
        for (var i = 0; i < N; i++) {
            var count = this.props.count + i;
            boxes.push(
                React.DOM.div({
                        className: "box-view",
                        key: i
                    },
                    React.DOM.div({
                            className: "box",
                            style: {
                                top: Math.sin(count / 10) * 10,
                                left: Math.cos(count / 10) * 10,
                                background: 'rgb(0, 0,' + count % 255 + ')'
                            }
                        },
                        count % 100
                    )
                )
            );
        }
        return React.DOM.div(null, boxes);
    }
});

var counter = 0;

var reactAnimate = function() {
    React.render(
        React.createElement(BoxesView, {count: counter++}),
        document.getElementById('example-container')
    );
    setTimeout(reactAnimate, 0);
};

setTimeout(reactAnimate, 0);
