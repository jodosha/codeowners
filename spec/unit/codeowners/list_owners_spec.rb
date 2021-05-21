# frozen_string_literal: true

RSpec.describe Codeowners::ListOwners do
  subject { described_class.new(Dir.pwd, codeowners) }
  let(:codeowners) { Pathname.new(Dir.pwd).join("spec", "support", "fixtures", "CODEOWNERS") }

  describe "#call" do
    # These owners will be the default owners for everything in
    # the repo. Unless a later match takes precedence,
    # @global-owner1 and @global-owner2 will be requested for
    # review when someone opens a pull request.
    #
    # *       @global-owner1 @global-owner2
    context "it matches any file" do
      it "returns owners for relative file" do
        expect(subject.call("file.c").owners).to eq(["@global-owner1", "@global-owner2"])
      end

      it "returns owners for absolute file" do
        expect(subject.call("/file.c").owners).to eq(["@global-owner1", "@global-owner2"])
      end
    end

    # Order is important; the last matching pattern takes the most
    # precedence. When someone opens a pull request that only
    # modifies JS files, only @js-owner and not the global
    # owner(s) will be requested for a review.
    #
    # *.js    @js-owner
    context "it matches .js files" do
      it "returns owners for relative file" do
        expect(subject.call("file.js").owners).to eq(["@js-owner"])
      end

      it "returns owners for absolute file" do
        expect(subject.call("/file.js").owners).to eq(["@js-owner"])
      end
    end

    # You can also use email addresses if you prefer. They'll be
    # used to look up users just like we do for commit author
    # emails.
    #
    # *.go docs@example.com
    context "it matches .go files" do
      it "returns owners for relative file" do
        expect(subject.call("file.go").owners).to eq(["docs@example.com"])
      end

      it "returns owners for absolute file" do
        expect(subject.call("/file.go").owners).to eq(["docs@example.com"])
      end
    end

    # In this example, @doctocat owns any files in the build/logs
    # directory at the root of the repository and any of its
    # subdirectories.
    #
    # /build/logs/ @doctocat
    context "it matches subdirectories from root directory" do
      it "returns owners for file at the first level" do
        expect(subject.call("/build/logs/configure.log").owners).to eq(["@doctocat"])
      end

      it "falls back to global owners when using relative path at the first level" do
        expect(subject.call("build/logs/configure.log").owners).to eq(["@global-owner1", "@global-owner2"])
      end

      it "returns owners for file at the nested level" do
        expect(subject.call("/build/logs/staging/artifacts/configure.log").owners).to eq(["@doctocat"])
      end

      it "falls back to global owners when using relative path at the first level" do
        expect(subject.call("build/logs/staging/artifacts/configure.log").owners).to eq(["@global-owner1", "@global-owner2"])
      end

      it "overrides *.go rule" do
        expect(subject.call("/build/logs/tail.go").owners).to eq(["@doctocat"])
      end

      it "falls back to go owners when using relative path for *.go file" do
        expect(subject.call("build/logs/tail.go").owners).to eq(["docs@example.com"])
      end
    end

    # The `docs/*` pattern will match files like
    # `docs/getting-started.md` but not further nested files like
    # `docs/build-app/troubleshooting.md`.
    #
    # docs/*  docs@example.com
    context "it matches first level of subdirectories" do
      it "returns owners for the relative path" do
        expect(subject.call("docs/getting-started.md").owners).to eq(["docs@example.com"])
      end

      it "falls back to global owners when using nested relative path" do
        expect(subject.call("docs/build-app/troubleshooting.md").owners).to eq(["@global-owner1", "@global-owner2"])
      end

      it "overrides *.go rule" do
        expect(subject.call("docs/documentation.go").owners).to eq(["docs@example.com"])
      end
    end

    # In this example, @octocat owns any file in an apps directory
    # anywhere in your repository.
    #
    # apps/ @octocat
    context "it matches directory everywhere in the code base" do
      it "it matches at the first level with relative path" do
        expect(subject.call("apps/web.rb").owners).to eq(["@octocat"])
      end

      xit "it matches at the first level with absolute path" do
        expect(subject.call("/apps/web.rb").owners).to eq(["@octocat"])
      end

      it "it matches at the nested level with relative path" do
        expect(subject.call("apps/admin/config/routes.rb").owners).to eq(["@octocat"])
      end

      xit "it matches at the first level with absolute path" do
        expect(subject.call("/apps/admin/config/routes.rb").owners).to eq(["@octocat"])
      end

      it "overrides *.go rule for relative path" do
        expect(subject.call("apps/bench.go").owners).to eq(["@octocat"])
      end

      xit "overrides *.go rule for absolute path" do
        expect(subject.call("/apps/bench.go").owners).to eq(["@octocat"])
      end

      xit "matches apps/ directory when nested" do
        expect(subject.call("spec/apps/web_spec.rb").owners).to eq(["@octocat"])
      end
    end

    # In this example, @doctocat owns any file in the `/docs`
    # directory in the root of your repository.
    #
    # /docs/ @doctocat
    context "it matches absolute path" do
      it "returns owners that owns the absolute path at the first level" do
        expect(subject.call("/docs/getting-started.md").owners).to eq(["@doctocat"])
      end

      it "returns owners that owns the absolute path at the nested level" do
        expect(subject.call("/docs/build-app/troubleshooting.md").owners).to eq(["@doctocat"])
      end

      it "returns owners that owns the absolute path" do
        expect(subject.call("/docs/documentation.go").owners).to eq(["@doctocat"])
      end
    end
  end
end
