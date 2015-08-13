(function(window, React) {
    var ProxyClass = React.createClass({
        componentWillMount: function () {
            this.props.willMount(this);
            this.setState({renderedComponent: this.props.renderedComponent});
        },
        render: function () {
            return this.state.renderedComponent;
        },
        componentDidMount: function () {
            this.props.didMount();
        },
        componentWillReceiveProps: function (nextProps) {
            this.setState({renderedComponent: nextProps.renderedComponent});
        },
        componentDidUpdate: function () {
            this.props.didUpdate();
        },
        componentWillUnmount: function () {
            this.props.willUnmount();
        }
    });

    window.Twitch = {
        createFactory: function() {
            return React.createFactory(ProxyClass);
        }
    };
})(window, React);
