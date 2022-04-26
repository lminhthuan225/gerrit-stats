import "bootstrap/dist/css/bootstrap.css";
import "./style/base.scss";

import React from "react"; // eslint-disable-line no-unused-vars
import ReactDOM from "react-dom";
import { Router, Route, hashHistory } from "react-router";
import PageHeader from "./common/header/PageHeader";
import GlobalJavascriptLoader from "./common/loader/GlobalJavascriptLoader";
import PageFooter from "./common/PageFooter";
import SelectedUsers from "./common/model/SelectedUsers";

import OverviewPage from "./overview/OverviewPage";
import ProfilePage from "./profile/ProfilePage";
import projects from "./projects";

var jsLoader = new GlobalJavascriptLoader();

function onDatasetOverviewLoaded() {
  const storageKey = window.datasetOverview.hashCode;
  currentSelection.selectedUsers = SelectedUsers.fromLocalStorage(
    storageKey,
    window.ids
  );
  renderPage();
}

function onIdsLoaded(projectName) {
  jsLoader.loadJavascriptFile(
    "./data/" + projectName + "/datasetOverview.js",
    onDatasetOverviewLoaded
  );
}

function loadData(projectName) {
  jsLoader.loadJavascriptFile("./data/" + projectName + "/ids.js", function () {
    onIdsLoaded(projectName);
  });
}
loadData("farm-control");

// The dataset overview is also globally stored
window.datasetOverview = {};

var currentSelection = {
  selectedUsers: {},
};

function onCurrentSelectionChanged(newSelection) {
  currentSelection.selectedUsers = newSelection.selectedUsers;
  currentSelection.selectedUsers.writeToStorage();
}

function getSubtitleFromDatasetName() {
  const datasetOverview = window.datasetOverview;
  var dataSetName = datasetOverview["projectName"];
  var filenames = datasetOverview["filenames"];
  if (filenames && filenames.length > 20) {
    var firstFilename = filenames[0];
    var lastFilename = filenames[datasetOverview.filenames.length - 1];
    dataSetName =
      filenames.length +
      " files, from " +
      firstFilename +
      " to " +
      lastFilename;
  }
  return dataSetName;
}

// Called when preconditions are complete (data is loaded).
function renderPage() {
  const headerProps = {
    datasetOverview: window.datasetOverview,
    selectedUsers: currentSelection.selectedUsers,
    subtitle: getSubtitleFromDatasetName(),
  };
  let isIncludedQuestionmark = false;
  const url = window.location.href;
  let projectName = "farm-control";
  if (url.includes("?")) {
    isIncludedQuestionmark = true;
    const searchParams = url.split("?")[1].split("&");
    searchParams.forEach((param) => {
      if (param.split("=")[0] === "project") {
        projectName = param.split("=")[1];
      }
    });
  }
  const urlPrefix = isIncludedQuestionmark
    ? window.location.href.split("?")[0]
    : window.location.href;

  console.log(urlPrefix);

  ReactDOM.render(
    <div style={{ minHeight: "100vh" }}>
      <Router history={hashHistory}>
        <Route
          path="/"
          exact
          component={() => (
            <div>
              <PageHeader {...headerProps} />
              <div style={{ height: "500px", width: "100%" }}>
                <ul>
                  {projects.projects.map((project) => (
                    <li key={project}>
                      <a
                        href={`/GerritStats/out-html/index.html#/project/${project}`}
                      >
                        {project}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        ></Route>
        <Route
          path="/project/:identifier"
          component={OverviewPage}
          datasetOverview={window.datasetOverview}
          currentSelection={currentSelection}
          onCurrentSelectionChanged={onCurrentSelectionChanged}
          loadData={loadData}
        />
        <Route
          path="/profile/:identifier/:projectName"
          component={ProfilePage}
          datasetOverview={window.datasetOverview}
          currentSelection={currentSelection}
        />
      </Router>
      <PageFooter datasetOverview={window.datasetOverview} />
    </div>,
    document.getElementById("app")
  );
}
