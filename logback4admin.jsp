<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="ch.qos.logback.classic.Level" %>
<%@ page import="ch.qos.logback.classic.Logger" %>
<%@ page import="ch.qos.logback.classic.LoggerContext" %>
<%@ page import="org.slf4j.LoggerFactory" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="ch.qos.logback.classic.joran.JoranConfigurator" %>
<%@ page import="ch.qos.logback.classic.util.ContextInitializer" %>
<% long beginPageLoadTime = System.currentTimeMillis();%>

<html>
<head>
    <title>Logback Administration</title>
    <style type="text/css">

        <!--
        #content {
            margin: 0px;
            padding: 0px;
            text-align: center;
            background-color: #add8e6;
            border: 1px solid #00008b;
            width: 100%;
        }

        body {
            position: relative;
            margin: 10px;
            padding: 0px;
            color: #333;
        }

        h1 {
            margin-top: 20px;
            font: 1.5em Verdana, Arial, Helvetica sans-serif;
        }

        h2 {
            margin-top: 10px;
            font: 0.75em Verdana, Arial, Helvetica sans-serif;
            text-align: left;
        }

        a, a:link, a:visited, a:active {
            color: blue;
            text-decoration: none;
            text-transform: uppercase;
        }

        table {
            width: 100%;
            background-color: #000;
            padding: 3px;
            border: 0px;
        }

        th {
            font-size: 0.75em;
            background-color: #add8e6;
            color: #000;
            padding-left: 5px;
            text-align: center;
            border: 1px solid #ccc;
            white-space: nowrap;
        }

        td {
            font-size: 0.75em;
            white-space: nowrap;
        }

        td.center {
            font-size: 0.75em;
            text-align: center;
            white-space: nowrap;
        }

        .filter-form {
            font-size: 0.9em;
            background-color: #00008b;
            color: #fff;
            padding-left: 5px;
            text-align: left;
            border: 1px solid #00008b;
            white-space: nowrap;
        }

        .filter-text {
            font-size: 0.75em;
            background-color: #fff;
            color: #000;
            text-align: left;
            border: 1px solid #ccc;
            white-space: nowrap;
        }

        .filter-button {
            font-size: 0.75em;
            background-color: #00008b;
            color: #fff;
            padding-left: 5px;
            padding-right: 5px;
            text-align: center;
            border: 1px solid #ccc;
            width: 100px;
            white-space: nowrap;
        }

        .action-button {
            font-size: 0.75em;
            background-color: #ccc;
            color: #000;
            padding-left: 5px;
            padding-right: 5px;
            text-align: center;
            border: 1px solid #ccc;
            width: 100px;
            white-space: nowrap;
        }

        .row-odd {
            background-color: #ffffff;
        }

        .row-even {
            background-color: #F6F6F6;
        }

        -->
    </style>
</head>

<body onLoad="javascript:document.logFilterForm.logNameFilter.focus();">

<%
    String ROOT_LOGER_KEY = "!";

    String CONTAINS_FILTER = "Contains";
    String BEGIN_WITH_FILTER = "Begins With";
    String RESET_ACTION = "Reset";

    String[] logLevels = {"debug", "info", "warn", "error", "fatal", "off"};

    // parameters
    String paramOperation = request.getParameter("operation");
    String paramLogger = request.getParameter("logger");
    String paramLogLevel = request.getParameter("newLogLevel");
    String paramLogNameFilter = request.getParameter("logNameFilter");
    String paramLogNameFilterType = request.getParameter("logNameFilterType");
    String paramReset = request.getParameter("reset");

    int rowCounter = 0;

%>
<div id="content">
    <h1>Logback Administration</h1>

    <div class="filter-form">

        <form action="logback4admin.jsp" name="logFilterForm">
            Filter Loggers:&nbsp;&nbsp;
            <input name="logNameFilter" type="text" size="50" value="<%=(paramLogNameFilter == null ? "":paramLogNameFilter)%>"
                   class="filter-text"/>

            <input name="logNameFilterType" type="submit" value="<%=BEGIN_WITH_FILTER%>" class="filter-button"/>&nbsp;

            <input name="logNameFilterType" type="submit" value="<%=CONTAINS_FILTER%>" class="filter-button"/>&nbsp;

            <input name="logNameClear" type="button" value="Clear" class="filter-button"
                   onmousedown='javascript:document.logFilterForm.logNameFilter.value="";'/>

            <input name="reset" type="submit" value="<%=RESET_ACTION%>" class="action-button"/>
            <param name="operation" value="changeLogLevel"/>
        </form>
    </div>

    <table cellspacing="1">
        <tr>
            <th width="35%">Logger</th>
            <th width="15%">Level</th>
            <th width="15%">Effective Level</th>
            <th width="35%">Change Log Level To</th>
        </tr>

        <%
            LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();

            if (RESET_ACTION.equals(paramReset)){
                JoranConfigurator configurator = new JoranConfigurator();
                configurator.setContext(context);
                // Call context.reset() to clear any previous configuration, e.g. default
                // configuration. For multi-step configuration, omit calling context.reset().
                context.reset();
                ContextInitializer ci = new ContextInitializer(context);
                ci.autoConfig();
            }

            Map<String, Logger> loggersMap = new TreeMap<String, Logger>();

            // fill the log map
            for (Logger logger : context.getLoggerList()) {
                if (Logger.ROOT_LOGGER_NAME.equalsIgnoreCase(logger.getName())) {
                    // put root logger always, will not be filtered
                    // root replacement for the TOP on the table
                    loggersMap.put(ROOT_LOGER_KEY, logger);
                } else if (paramLogNameFilter == null || paramLogNameFilter.trim().length() == 0) {
                    loggersMap.put(logger.getName(), logger);
                } else if (CONTAINS_FILTER.equals(paramLogNameFilterType)) {
                    if (logger.getName().toUpperCase().indexOf(paramLogNameFilter.toUpperCase()) >= 0) {
                        loggersMap.put(logger.getName(), logger);
                    }
                } else {
                    // Either was no filter in IF, contains filter in ELSE IF, or begins with in ELSE
                    if (logger.getName().startsWith(paramLogNameFilter)) {
                        loggersMap.put(logger.getName(), logger);
                    }
                }
            }

            // begin print the log map
            Set<Map.Entry<String, Logger>> entries = loggersMap.entrySet();
            rowCounter = 0;

            for (Map.Entry<String, Logger> entry: entries) {
                rowCounter++;
                Logger logger = entry.getValue();

                // MUST CHANGE THE LOG LEVEL ON LOGGER BEFORE GENERATING THE LINKS AND THE
                // CURRENT LOG LEVEL OR DISABLED LINK WON'T MATCH THE NEWLY CHANGED VALUES
                if ("changeLogLevel".equals(paramOperation) && paramLogger.equals(logger.getName())) {
                    Logger selectedLogger = loggersMap.get(paramLogger);
                    selectedLogger.setLevel(Level.toLevel(paramLogLevel));
                }

                String loggerName = null;
                String loggerLevel = null;
                String loggerEffectiveLevel = null;

                if (logger != null) {
                    loggerName = ROOT_LOGER_KEY.equals(entry.getKey()) ? Logger.ROOT_LOGGER_NAME : entry.getKey();
                    loggerLevel = (logger.getLevel() != null)? logger.getLevel().toString(): "";
                    loggerEffectiveLevel = String.valueOf(logger.getEffectiveLevel());
                }
        %>
                <tr class="<%=(rowCounter%2 == 1)?"row-odd":"row-even"%>">
                    <td>
                        <%=loggerName%>
                    </td>
                    <td>
                        <%=loggerLevel%>
                    </td>
                    <td>
                        <%=loggerEffectiveLevel%>
                    </td>

                    <td class="center">
                        <%
                            for (int cnt = 0; cnt < logLevels.length; cnt++) {

                                String url = "logback4admin.jsp?operation=changeLogLevel&logger=" + loggerName
                                        + "&newLogLevel=" + logLevels[cnt] + "&logNameFilter="
                                        + (paramLogNameFilter != null ? paramLogNameFilter : "")
                                        + "&logNameFilterType=" + (paramLogNameFilterType != null ? paramLogNameFilterType : "");

                            if (logger.getLevel() == Level.toLevel(logLevels[cnt]) || logger.getEffectiveLevel() == Level.toLevel(logLevels[cnt])) {
                                %>
                                [<%=logLevels[cnt].toUpperCase()%>]
                                <%
                                } else {
                                %>
                                <a href='<%=url%>'>[<%=logLevels[cnt]%>]</a>&nbsp;
                                <%
                                }
                            }
                        %>
                    </td>
                </tr>

        <%
            } // end for print the log map
        %>

    </table>

    <%-- footer --%>
    <h2>
        Revision: 1.0<br/>
        Page Load Time (Millis): <%=(System.currentTimeMillis() - beginPageLoadTime)%>
    </h2>

</div>
</body>
</html>
