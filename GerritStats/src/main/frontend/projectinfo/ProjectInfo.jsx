import React from "react";

import Panel from "../common/Panel";
import { Td, Tr } from "reactable";
import { Link } from "react-router";
import SimpleSortableTable from "../common/SimpleSortableTable";
import moment from "moment";

export default class ProjectInfo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      columnMetadata: this.getDefaultColumnMetadata(),
      projectInfo: {},
      projectData: this.props.projectData,
    };
  }

  // componentDidMount() {
  //   var jsLoader = new GlobalJavascriptLoader();
  //   jsLoader.loadJavascriptFile(
  //     "./data/" + this.props.projectName + "/overview.js",
  //     function () {
  //       this.setState({
  //         projectInfo: {
  //           ...projectInfo,
  //           []: window.overviewUserdata
  //         },
  //       });
  //     }.bind(this)
  //   );
  // }

  renderDate(date) {
    return date !== null ? moment(date).format("YYYY-MM-DD") : "\u2013";
  }

  getDefaultColumnMetadata() {
    // const overviewUserdata = this.props.overviewUserdata;
    // // Use props as this is only called in constructor
    // const selectedUsers = this.props.selectedUsers;

    return {
      // selected: {
      // header: () => (
      //   <input
      //     name="selectAll"
      //     type="checkbox"
      //     checked={this.state.selectedUsers.isAllUsersSelected()}
      //     onChange={this.onSelectAllCheckboxValueChanged.bind(this)}
      //   />
      // ),
      // cell: (record, index) => (
      //   <Td key={"selected" + index} column="selected">
      //     <input
      //       data-identifier={record.identifier}
      //       type="checkbox"
      //       checked={this.state.selectedUsers.isUserSelected(
      //         record.identifier
      //       )}
      //       onChange={() =>
      //         this.onIdentityCheckboxValueChanged(record.identifier)
      //       }
      //     />
      //   </Td>
      // ),
      // },
      name: {
        sortFunction: Reactable.Sort.CaseInsensitive,
        description: "The name of the user, as shown in Gerrit.",
        header: "Name",
        cell: (record, index) => (
          <Td
            key={"name" + index}
            column="name"
            // value={getPrintableName(record.name)}
            value={record.name}
          >
            <Link to={`/project/${record.name}`}>
              {/* {getPrintableName(record.identity)} */}
              {record.name}
            </Link>
          </Td>
        ),
      },
      totalCommits: {
        sortFunction: Reactable.Sort.NumericInteger,
        // highlighter: new TableCellHighlighter(
        //   overviewUserdata,
        //   selectedUsers,
        //   "reviewCountPlus2"
        // ),
        description: "",
        header: <span>Total Commits</span>,
        cell: (record, index) => (
          <Td
            key={"reviewCountPlus2" + index}
            column="totalCommits"
            // style={this.computeCellStyle(index, "reviewCountPlus2")}
          >
            {record.overviewUserdata.reduce(
              (acc, crt) => (acc += crt.commitCount),
              0
            )}
          </Td>
        ),
      },
      activeUsers: {
        sortFunction: Reactable.Sort.NumericInteger,
        // highlighter: new TableCellHighlighter(
        //   overviewUserdata,
        //   selectedUsers,
        //   "reviewCountPlus1"
        // ),
        description: "Number of users participating into this project",
        header: "Active Users",
        cell: (record, index) => (
          <Td
            key={"reviewCountPlus1" + index}
            column="activeUsers"
            // style={this.computeCellStyle(index, "reviewCountPlus1")}
          >
            {record.overviewUserdata.length}
          </Td>
        ),
      },
      fromDate: {
        sortFunction: Reactable.Sort.NumericInteger,
        // highlighter: new TableCellHighlighter(
        //   overviewUserdata,
        //   selectedUsers,
        //   "reviewCountPlus1"
        // ),
        description: "From Date",
        header: "From Date",
        cell: (record, index) => (
          <Td
            key={"reviewCountPlus1" + index}
            column="fromDate"
            // style={this.computeCellStyle(index, "reviewCountPlus1")}
          >
            {this.renderDate(record.datasetOverview["fromDate"])} 
          </Td>
        ),
      },
      toDate: {
        sortFunction: Reactable.Sort.NumericInteger,
        // highlighter: new TableCellHighlighter(
        //   overviewUserdata,
        //   selectedUsers,
        //   "reviewCountPlus1"
        // ),
        description: "To Date",
        header: "To Date",
        cell: (record, index) => (
          <Td
            key={"reviewCountPlus1" + index}
            column="toDate"
            // style={this.computeCellStyle(index, "reviewCountPlus1")}
          >
            {this.renderDate(record.datasetOverview["toDate"])}
          </Td>
        ),
      },
      //   reviewCountMinus1: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "reviewCountMinus1"
      //     ),
      //     description: "Number of -1 reviews given by this user.",
      //     header: (
      //       <span>
      //         -1
      //         <br />
      //         given
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"reviewCountMinus1" + index}
      //         column="reviewCountMinus1"
      //         style={this.computeCellStyle(index, "reviewCountMinus1")}
      //       >
      //         {record.reviewCountMinus1}
      //       </Td>
      //     ),
      //   },
      //   reviewCountMinus2: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "reviewCountMinus2"
      //     ),
      //     description: "Number of -2 reviews given by this user.",
      //     header: (
      //       <span>
      //         -2
      //         <br />
      //         given
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"reviewCountMinus2" + index}
      //         column="reviewCountMinus2"
      //         style={this.computeCellStyle(index, "reviewCountMinus2")}
      //       >
      //         {record.reviewCountMinus2}
      //       </Td>
      //     ),
      //   },
      //   allCommentsWritten: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "allCommentsWritten"
      //     ),
      //     description:
      //       "Number of review comments written to other people's commits by this user.",
      //     header: (
      //       <span>
      //         Comments
      //         <br />
      //         written
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"allCommentsWritten" + index}
      //         column="allCommentsWritten"
      //         style={this.computeCellStyle(index, "allCommentsWritten")}
      //       >
      //         {record.allCommentsWritten}
      //       </Td>
      //     ),
      //   },
      //   allCommentsReceived: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "allCommentsReceived"
      //     )
      //       .setIsAscending(true)
      //       .setIgnoreFunction((element) => element.commitCount == 0),
      //     description: "Number of review comments received by this user.",
      //     header: (
      //       <span>
      //         Comments
      //         <br />
      //         received
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"allCommentsReceived" + index}
      //         column="allCommentsReceived"
      //         style={this.computeCellStyle(index, "allCommentsReceived")}
      //       >
      //         {record.allCommentsReceived}
      //       </Td>
      //     ),
      //   },
      //   commitCount: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "commitCount"
      //     ).setIgnoreZeroes(true),
      //     description: "Number of commits made by this user.",
      //     header: "Commits",
      //     cell: (record, index) => (
      //       <Td
      //         key={"commitCount" + index}
      //         column="commitCount"
      //         style={this.computeCellStyle(index, "commitCount")}
      //       >
      //         {record.commitCount}
      //       </Td>
      //     ),
      //   },
      //   receivedCommentRatio: {
      //     sortFunction: decimalComparator,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "receivedCommentRatio"
      //     )
      //       .setIsAscending(true)
      //       .setIgnoreFunction((element) => element.commitCount == 0),
      //     description: "The ratio of comments received by user per commit.",
      //     header: (
      //       <span>
      //         Comments
      //         <br />/ commit
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"receivedCommentRatio" + index}
      //         column="receivedCommentRatio"
      //         value={record.receivedCommentRatio}
      //         style={this.computeCellStyle(index, "receivedCommentRatio")}
      //       >
      //         {numeral(record.receivedCommentRatio).format("0.000")}
      //       </Td>
      //     ),
      //   },
      //   reviewCommentRatio: {
      //     sortFunction: decimalComparator,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "reviewCommentRatio"
      //     ),
      //     description:
      //       "The ratio of comments written by this user per a review request.",
      //     header: (
      //       <span>
      //         Comments
      //         <br />/ review
      //         <br />
      //         requests
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"reviewCommentRatio" + index}
      //         column="reviewCommentRatio"
      //         value={record.reviewCommentRatio}
      //         style={this.computeCellStyle(index, "reviewCommentRatio")}
      //       >
      //         {numeral(record.reviewCommentRatio).format("0.000")}
      //       </Td>
      //     ),
      //   },
      //   addedAsReviewerToCount: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "addedAsReviewerToCount"
      //     ),
      //     description: "Number of times this user was added as a reviewer.",
      //     header: (
      //       <span>
      //         Added as
      //         <br />
      //         reviewer
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"addedAsReviewerToCount" + index}
      //         column="addedAsReviewerToCount"
      //         style={this.computeCellStyle(index, "addedAsReviewerToCount")}
      //       >
      //         {record.addedAsReviewerToCount}
      //       </Td>
      //     ),
      //   },
      //   selfReviewedCommitCount: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "selfReviewedCommitCount"
      //     )
      //       .setIsAscending(true)
      //       .setHighlightPositiveEntries(false)
      //       .setIgnoreZeroes(true),
      //     description:
      //       "Number of times the user merged a change after self-reviewing it, without having any reviews in any patch set from other users.",
      //     header: "Self-reviews",
      //     cell: (record, index) => (
      //       <Td
      //         key={"selfReviewedCommitCount" + index}
      //         column="selfReviewedCommitCount"
      //         style={this.computeCellStyle(index, "selfReviewedCommitCount")}
      //       >
      //         {record.selfReviewedCommitCount}
      //       </Td>
      //     ),
      //   },
      //   averageTimeInCodeReview: {
      //     sortFunction: Reactable.Sort.NumericInteger,
      //     highlighter: new TableCellHighlighter(
      //       overviewUserdata,
      //       selectedUsers,
      //       "averageTimeInCodeReview"
      //     )
      //       .setIsAscending(true)
      //       .setIgnoreZeroes(true),
      //     description: "Average time the user's commits spent in review.",
      //     header: (
      //       <span>
      //         Average time
      //         <br />
      //         in review
      //       </span>
      //     ),
      //     cell: (record, index) => (
      //       <Td
      //         key={"averageTimeInCodeReview" + index}
      //         column="averageTimeInCodeReview"
      //         value={record.averageTimeInCodeReview}
      //         style={this.computeCellStyle(index, "averageTimeInCodeReview")}
      //       >
      //         {formatPrintableDuration(record.averageTimeInCodeReview)}
      //       </Td>
      //     ),
      //   },
    };
  }

  renderRow(index, overviewRecord) {
    // const isUserSelected = this.state.selectedUsers.isUserSelected(
    //   overviewRecord.identifier
    // );

    // const selectionStyle = {
    //   color: isUserSelected ? "" : OverviewTable.COLOR_UNSELECTED,
    // };

    var rowCells = Object.keys(this.state.columnMetadata).map(
      function (columnName) {
        const metadata = this.state.columnMetadata[columnName];
        return metadata.cell(overviewRecord, index);
      }.bind(this)
    );
    //style={selectionStyle}
    return <Tr key={"r_" + index}>{rowCells}</Tr>;
  }

  render() {
    document.title = "All Gerrit Projects"

    return (
      <div>
        <Panel title="All Projects" size="flex">
          <SimpleSortableTable
            columnMetadata={this.state.columnMetadata}
            rowData={this.props.projectData}
            rowRenderer={this.renderRow.bind(this)}
          />
        </Panel>
      </div>
    );
  }
}
