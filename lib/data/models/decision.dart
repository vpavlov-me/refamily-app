class Decision {
  final String id;
  final String title;
  final String description;
  final String status;
  final String type;
  final String priority;
  final DateTime createdAt;
  final String createdBy;
  final DateTime deadline;
  final DateTime? closedAt;
  final String? result;
  final List<Proposal> proposals;
  final String? myVote;
  final int requiredVotes;
  final int totalVotes;
  final int votesFor;
  final int votesAgainst;
  final int votesAbstain;
  final List<Comment> comments;

  const Decision({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.type,
    required this.priority,
    required this.createdAt,
    required this.createdBy,
    required this.deadline,
    this.closedAt,
    this.result,
    required this.proposals,
    this.myVote,
    required this.requiredVotes,
    required this.totalVotes,
    this.votesFor = 0,
    this.votesAgainst = 0,
    this.votesAbstain = 0,
    this.comments = const [],
  });

  bool get hasVoted => myVote != null;
  bool get isActive => status == 'Voting' || status == 'Pending';
  
  int get daysRemaining {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      closedAt: json['closedAt'] != null 
          ? DateTime.parse(json['closedAt'] as String) 
          : null,
      result: json['result'] as String?,
      proposals: (json['proposals'] as List<dynamic>?)
          ?.map((e) => Proposal.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      myVote: json['myVote'] as String?,
      requiredVotes: json['requiredVotes'] as int,
      totalVotes: json['totalVotes'] as int,
      votesFor: json['votesFor'] as int? ?? 0,
      votesAgainst: json['votesAgainst'] as int? ?? 0,
      votesAbstain: json['votesAbstain'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'type': type,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'deadline': deadline.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'result': result,
      'proposals': proposals.map((e) => e.toJson()).toList(),
      'myVote': myVote,
      'requiredVotes': requiredVotes,
      'totalVotes': totalVotes,
      'votesFor': votesFor,
      'votesAgainst': votesAgainst,
      'votesAbstain': votesAbstain,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  Decision copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? type,
    String? priority,
    DateTime? createdAt,
    String? createdBy,
    DateTime? deadline,
    DateTime? closedAt,
    String? result,
    List<Proposal>? proposals,
    String? myVote,
    int? requiredVotes,
    int? totalVotes,
    int? votesFor,
    int? votesAgainst,
    int? votesAbstain,
    List<Comment>? comments,
  }) {
    return Decision(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      deadline: deadline ?? this.deadline,
      closedAt: closedAt ?? this.closedAt,
      result: result ?? this.result,
      proposals: proposals ?? this.proposals,
      myVote: myVote ?? this.myVote,
      requiredVotes: requiredVotes ?? this.requiredVotes,
      totalVotes: totalVotes ?? this.totalVotes,
      votesFor: votesFor ?? this.votesFor,
      votesAgainst: votesAgainst ?? this.votesAgainst,
      votesAbstain: votesAbstain ?? this.votesAbstain,
      comments: comments ?? this.comments,
    );
  }
}

class Proposal {
  final String id;
  final String title;
  final String description;
  final String author;
  final String content;
  final DateTime createdAt;
  final int votes;
  final List<String> voters;

  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.votes,
    required this.voters,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      votes: json['votes'] as int? ?? 0,
      voters: (json['voters'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'votes': votes,
      'voters': voters,
    };
  }
}

class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DecisionsSummary {
  final int total;
  final int voting;
  final int pending;
  final int approved;
  final int rejected;

  const DecisionsSummary({
    required this.total,
    required this.voting,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory DecisionsSummary.fromJson(Map<String, dynamic> json) {
    return DecisionsSummary(
      total: json['total'] as int,
      voting: json['voting'] as int,
      pending: json['pending'] as int,
      approved: json['approved'] as int,
      rejected: json['rejected'] as int,
    );
  }
}
